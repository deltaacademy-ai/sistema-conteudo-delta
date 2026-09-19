#!/usr/bin/env node
// Render do carrossel: carrossel.json + marca.md -> 01.png a NN.png (1080x1350) + carrossel.pdf,
// tudo do mesmo HTML, com fontes locais. Confere o proprio resultado antes de declarar sucesso.
//
// uso:
//   node scripts/render-carrossel.mjs <carrossel.json> [pasta-saida] [--marca marca.md] [--fontes pasta] [--so-html]
//   node scripts/render-carrossel.mjs <slides.html> <pasta-saida>
//
// Sem pasta-saida, a saida e a pasta do carrossel.json (a pasta da peca).
// Sem --marca, procura marca.md subindo ate 4 niveis a partir do json; sem achar, aplica os
// padroes de template/tokens.css e diz isso na saida.
// Saida 0: tudo conferido. Saida 1: falha (fonte ausente, contraste, tamanho, PDF com fonte
// estranha, texto fora do quadro). Saida 2: sem Playwright ou Chromium; o HTML ficou pronto
// na pasta e a mensagem diz como abrir e exportar.

import { readFile, writeFile, mkdir, copyFile, readdir, stat } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const AQUI = path.dirname(fileURLToPath(import.meta.url));
const SKILL = path.join(AQUI, '..', 'skills', 'carrossel-render');
const TEMPLATE = path.join(SKILL, 'template', 'slide.html');
const FONTES_SKILL = path.join(SKILL, 'fonts');
const LARGURA = 1080, ALTURA = 1350;

const PADRAO = {
  cores: { fundo: '#141414', destaque: '#9aa4b2', claro: '#f2f2ee' },
  fontes: { display: 'Cal Sans', texto: 'DM Sans', mono: 'JetBrains Mono' },
};

// ---------- argumentos ----------

function lerArgs(argv) {
  const a = { posicionais: [], marca: null, fontes: [], soHtml: false };
  for (let i = 0; i < argv.length; i++) {
    const x = argv[i];
    if (x === '--marca') a.marca = argv[++i];
    else if (x === '--fontes') a.fontes.push(argv[++i]);
    else if (x === '--so-html') a.soHtml = true;
    else a.posicionais.push(x);
  }
  return a;
}

function falhar(msg) {
  console.error('FALHA: ' + msg);
  process.exit(1);
}

// ---------- marca.md -> tokens ----------

const semAcento = (s) => s.normalize('NFD').replace(/[̀-ͯ]/g, '');
const kebab = (s) => semAcento(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

function limparValor(v) {
  return v.replace(/`/g, '').replace(/\[[^\]]*\]/g, '').replace(/\([^)]*\)/g, '').trim().replace(/[.;]$/, '').trim();
}

function lerMarca(texto) {
  const marca = { cores: {}, fontes: {}, handle: '', dominio: '', avisos: [] };
  let secao = '';
  for (const bruta of texto.split('\n')) {
    const linha = bruta.trim();
    if (/^#{1,6}\s/.test(linha)) { secao = kebab(linha.replace(/^#+\s*/, '')); continue; }
    if (!linha) continue;
    const semMarcador = linha.replace(/^[-*]\s+/, '');
    const dois = semMarcador.indexOf(':');
    const chave = dois >= 0 ? kebab(semMarcador.slice(0, dois)) : '';
    const valor = dois >= 0 ? semMarcador.slice(dois + 1) : semMarcador;
    const falta = /\[FALTA/i.test(semMarcador);

    if (secao.startsWith('cor')) {
      const hex = valor.match(/#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b/);
      let papel = '';
      if (/fundo|escur|background|base/.test(chave)) papel = 'fundo';
      else if (/destaque|acento|accent|primar|principal/.test(chave)) papel = 'destaque';
      else if (/clar|texto|text|light|branc/.test(chave)) papel = 'claro';
      if (falta || !hex) { if (papel) marca.avisos.push(`marca.md: cor "${papel}" sem hex`); continue; }
      if (!papel) { marca.avisos.push(`marca.md: cor ${hex[0]} sem papel (fundo, destaque ou claro); ignorada`); continue; }
      if (!marca.cores[papel]) marca.cores[papel] = hex[0].toLowerCase();
    } else if (secao.startsWith('font')) {
      let papel = '';
      if (/display|titul|heading|headline/.test(chave)) papel = 'display';
      else if (/texto|corpo|body|sans/.test(chave)) papel = 'texto';
      else if (/rotulo|codigo|mono|label/.test(chave)) papel = 'mono';
      const nome = limparValor(valor);
      if (!papel || falta || !nome) { if (papel) marca.avisos.push(`marca.md: fonte "${papel}" sem nome`); continue; }
      if (!marca.fontes[papel]) marca.fontes[papel] = nome;
    } else if (secao.startsWith('identifica')) {
      const h = semMarcador.match(/@[A-Za-z0-9_.]+/);
      if (h && !marca.handle) marca.handle = h[0];
      if (/dominio|site|url/.test(chave) && !falta) {
        const d = limparValor(valor).replace(/^https?:\/\//, '').replace(/\/$/, '');
        if (d && !marca.dominio) marca.dominio = d;
      }
    }
  }
  return marca;
}

function luminancia(hex) {
  let h = hex.replace('#', '');
  if (h.length === 3) h = h.split('').map((c) => c + c).join('');
  const c = [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255)
    .map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
}
function contraste(a, b) {
  const [l1, l2] = [luminancia(a), luminancia(b)].sort((x, y) => y - x);
  return (l1 + 0.05) / (l2 + 0.05);
}

async function acharArquivosFonte(familia, pastas) {
  const base = kebab(familia);
  const achados = [];
  for (const pasta of pastas) {
    if (!pasta || !existsSync(pasta)) continue;
    for (const f of await readdir(pasta)) {
      const m = f.match(/^(.+?)(?:-(\d{3}))?\.(woff2|woff|ttf|otf)$/i);
      if (m && m[1].toLowerCase() === base) achados.push({ arquivo: path.join(pasta, f), nome: f, peso: m[2] || null, formato: m[3].toLowerCase() });
    }
    if (achados.length) break; // a primeira pasta que tem a familia manda (contexto antes da skill)
  }
  return achados;
}

function fontFace(familia, f) {
  const formato = { woff2: 'woff2', woff: 'woff', ttf: 'truetype', otf: 'opentype' }[f.formato];
  const peso = f.peso ? f.peso : '100 900';
  return `@font-face { font-family: '${familia}'; font-weight: ${peso}; font-style: normal; font-display: block; src: url('fonts/${f.nome}') format('${formato}'); }`;
}

async function montarTokens(marca, pastasFonte, saida) {
  const padroes = [];
  const cores = {};
  for (const k of ['fundo', 'destaque', 'claro']) {
    if (marca.cores[k]) cores[k] = { valor: marca.cores[k], origem: 'marca.md' };
    else { cores[k] = { valor: PADRAO.cores[k], origem: 'padrao' }; padroes.push(`cor ${k} = ${PADRAO.cores[k]}`); }
  }
  const fontes = {};
  for (const k of ['display', 'texto', 'mono']) {
    if (marca.fontes[k]) fontes[k] = { valor: marca.fontes[k], origem: 'marca.md' };
    else { fontes[k] = { valor: PADRAO.fontes[k], origem: 'padrao' }; padroes.push(`fonte ${k} = ${PADRAO.fontes[k]}`); }
  }

  const razaoTexto = contraste(cores.fundo.valor, cores.claro.valor);
  if (razaoTexto < 4.5) falhar(`contraste entre fundo ${cores.fundo.valor} e claro ${cores.claro.valor} e ${razaoTexto.toFixed(2)}:1, abaixo de 4.5:1; o texto nao vai dar para ler. Ajuste as cores em marca.md.`);
  const avisos = [...marca.avisos];
  const razaoDestaque = contraste(cores.fundo.valor, cores.destaque.valor);
  if (razaoDestaque < 3) avisos.push(`destaque ${cores.destaque.valor} sobre fundo ${cores.fundo.valor} tem contraste ${razaoDestaque.toFixed(2)}:1 (abaixo de 3:1); o destaque some nos marcadores e no fecho`);

  const familias = [...new Set(Object.values(fontes).map((f) => f.valor))];
  const faces = [];
  const copiar = [];
  for (const familia of familias) {
    const arquivos = await acharArquivosFonte(familia, pastasFonte);
    if (!arquivos.length) {
      falhar(`fonte "${familia}" declarada e sem arquivo local. Coloque ${kebab(familia)}.woff2 (ou ${kebab(familia)}-400.woff2, ${kebab(familia)}-700.woff2) em uma pasta fonts/ ao lado de marca.md, ou passe --fontes <pasta>, ou troque a fonte em marca.md. O render nao usa fonte de sistema no lugar. Pastas consultadas: ${pastasFonte.filter(Boolean).join(', ')}`);
    }
    for (const f of arquivos) { faces.push(fontFace(familia, f)); copiar.push(f); }
  }

  await mkdir(path.join(saida, 'fonts'), { recursive: true });
  for (const f of copiar) await copyFile(f.arquivo, path.join(saida, 'fonts', f.nome));

  const linhaCor = (k) => `  --${k}: ${cores[k].valor}; /* ${cores[k].origem === 'padrao' ? 'padrao: marca.md sem esta cor' : 'marca.md'} */`;
  const linhaFonte = (k) => `  --fonte-${k}: '${fontes[k].valor}'; /* ${fontes[k].origem === 'padrao' ? 'padrao: marca.md sem esta fonte' : 'marca.md'} */`;
  const css = [
    '/* tokens.css: gerado por scripts/render-carrossel.mjs a partir de marca.md. Nao edite aqui; edite marca.md. */',
    ':root {',
    linhaCor('fundo'), linhaCor('destaque'), linhaCor('claro'),
    linhaFonte('display'), linhaFonte('texto'), linhaFonte('mono'),
    '}',
    '',
    ...faces,
    '',
  ].join('\n');
  await writeFile(path.join(saida, 'tokens.css'), css);
  return { cores, fontes, familias, padroes, avisos, arquivosFonte: copiar.map((f) => f.nome) };
}

// ---------- carrossel.json -> HTML ----------

const escapar = (s) => String(s ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

function validarCarrossel(j) {
  if (!j || !Array.isArray(j.slides) || !j.slides.length) falhar('carrossel.json sem lista "slides"');
  if (j.slides.length > 10) falhar(`carrossel.json com ${j.slides.length} slides; o maximo e 10`);
  j.slides.forEach((s, i) => {
    for (const k of ['tipo', 'titulo', 'corpo', 'apoio']) if (typeof s[k] !== 'string') falhar(`slide ${i + 1}: campo "${k}" ausente ou nao e string`);
    if (!['capa', 'conteudo', 'fecho'].includes(s.tipo)) falhar(`slide ${i + 1}: tipo "${s.tipo}" desconhecido (capa, conteudo ou fecho)`);
    if (!s.titulo.trim()) falhar(`slide ${i + 1}: titulo vazio`);
  });
  if (j.slides[0].tipo !== 'capa') falhar('o primeiro slide precisa ser "capa"');
  if (j.slides.length > 1 && j.slides.at(-1).tipo !== 'fecho') falhar('o ultimo slide precisa ser "fecho"');
}

async function montarHtml(j, marca, saida) {
  const modelo = await readFile(TEMPLATE, 'utf8');
  const pegar = (id) => {
    const m = modelo.match(new RegExp(`<template id="${id}">([\\s\\S]*?)</template>`));
    if (!m) falhar(`template/slide.html sem <template id="${id}">`);
    return m[1].trim();
  };
  const blocos = { capa: pegar('capa'), conteudo: pegar('conteudo'), fecho: pegar('fecho') };
  const total = j.slides.length;
  const slides = j.slides.map((s, i) => {
    const linhas = s.corpo.split('\n').map((l) => l.trim()).filter(Boolean)
      .map((l) => `<p class="linha">${escapar(l)}</p>`).join('');
    const campos = {
      titulo: escapar(s.titulo.replace(/\s*\n\s*/g, ' ')),
      apoio: escapar(s.apoio),
      corpo_linhas: linhas,
      handle: escapar(marca.handle),
      dominio: escapar(marca.dominio),
      pagina: `${String(i + 1).padStart(2, '0')} / ${String(total).padStart(2, '0')}`,
      avanco: `${((i + 1) / total * 100).toFixed(1)}%`,
    };
    let html = blocos[s.tipo].replace(/\{\{(\w+)\}\}/g, (_, k) => campos[k] ?? '');
    // paragrafo vazio nao ocupa lugar
    html = html.replace(/<p class="apoio"><\/p>/, '').replace(/<div class="corpo"><\/div>/, '');
    return html;
  });
  const cabeca = modelo.replace(/<template id="\w+">[\s\S]*?<\/template>\s*/g, '');
  const html = cabeca
    .replace('{{titulo_pdf}}', escapar(j.titulo_pdf || j.slides[0].titulo))
    .replace('<!--SLIDES-->', slides.join('\n'));
  const arquivo = path.join(saida, 'slides.html');
  await writeFile(arquivo, html);
  return arquivo;
}

// ---------- conferencias no artefato ----------

async function tamanhoPng(arquivo) {
  const b = await readFile(arquivo);
  if (b.readUInt32BE(0) !== 0x89504e47) return null;
  return { largura: b.readUInt32BE(16), altura: b.readUInt32BE(20) };
}

function fontesDoPdf(buffer) {
  const texto = buffer.toString('latin1');
  const nomes = new Set();
  for (const m of texto.matchAll(/\/BaseFont\s*\/([^\s\/>\]]+)/g)) nomes.add(m[1]);
  const paginas = (texto.match(/\/Type\s*\/Page(?![s\w])/g) || []).length;
  return { nomes: [...nomes].sort(), paginas };
}

const normalizar = (s) => s.toLowerCase().replace(/^[a-z]{6}\+/, '').replace(/[^a-z0-9]/g, '');

// ---------- render ----------

async function renderizar(htmlPath, saida, familias) {
  let chromium;
  try { ({ chromium } = await import('playwright')); }
  catch { return { semMotor: 'Playwright nao esta instalado (npm i playwright).' }; }
  let browser;
  try { browser = await chromium.launch({ args: ['--force-color-profile=srgb', '--hide-scrollbars'] }); }
  catch (e) { return { semMotor: `Chromium do Playwright nao abriu (npx playwright install chromium). Detalhe: ${e.message.split('\n')[0]}` }; }

  const page = await browser.newPage({ viewport: { width: LARGURA, height: ALTURA }, deviceScaleFactor: 1 });
  const erros = [];
  page.on('requestfailed', (r) => erros.push(`recurso falhou: ${r.url()}`));
  await page.goto('file://' + path.resolve(htmlPath), { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);

  // Forca o carregamento de cada @font-face e acusa qualquer uma que nao carregou.
  const fontes = await page.evaluate(async () => {
    const faces = [...document.fonts];
    await Promise.all(faces.map((f) => f.load().catch(() => null)));
    return faces.map((f) => ({ familia: f.family.replace(/^['"]|['"]$/g, ''), peso: f.weight, status: f.status }));
  });
  const naoCarregou = fontes.filter((f) => f.status !== 'loaded');
  if (naoCarregou.length) { await browser.close(); falhar(`fonte nao carregou no navegador: ${naoCarregou.map((f) => `${f.familia} ${f.peso} (${f.status})`).join(', ')}. ${erros.join('; ')}`); }
  const faltando = familias.filter((f) => !fontes.some((x) => x.familia === f));
  if (faltando.length) { await browser.close(); falhar(`tokens.css nao declara @font-face para: ${faltando.join(', ')}`); }

  // Ajusta --escala por slide ate o miolo caber; registra o que nao coube mesmo assim.
  const ajuste = await page.evaluate(() => {
    const r = [];
    document.querySelectorAll('.slide').forEach((slide, i) => {
      const miolo = slide.querySelector('.miolo');
      let escala = 1;
      const cabe = () => miolo.scrollHeight <= miolo.clientHeight && slide.scrollWidth <= slide.clientWidth;
      while (!cabe() && escala > 0.6) { escala = +(escala - 0.05).toFixed(2); slide.style.setProperty('--escala', String(escala)); }
      r.push({ slide: i + 1, escala, cabe: cabe() });
    });
    return r;
  });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(150);

  const slides = await page.$$('.slide');
  const pngs = [];
  for (const [i, slide] of slides.entries()) {
    const arquivo = path.join(saida, String(i + 1).padStart(2, '0') + '.png');
    await slide.screenshot({ path: arquivo, type: 'png' });
    pngs.push(arquivo);
  }
  const pdf = path.join(saida, 'carrossel.pdf');
  await page.pdf({ path: pdf, width: `${LARGURA}px`, height: `${ALTURA}px`, printBackground: true, preferCSSPageSize: true, margin: { top: 0, right: 0, bottom: 0, left: 0 } });
  await browser.close();
  return { pngs, pdf, ajuste, fontes, erros };
}

// ---------- principal ----------

async function main() {
  const args = lerArgs(process.argv.slice(2));
  const [entrada, saidaArg] = args.posicionais;
  if (!entrada) { console.error('uso: node scripts/render-carrossel.mjs <carrossel.json|slides.html> [pasta-saida] [--marca marca.md] [--fontes pasta] [--so-html]'); process.exit(1); }
  if (!existsSync(entrada)) falhar(`entrada nao existe: ${entrada}`);

  const ehJson = entrada.toLowerCase().endsWith('.json');
  const saida = path.resolve(saidaArg || (ehJson ? path.dirname(entrada) : falhar('com entrada .html, informe a pasta de saida')));
  await mkdir(saida, { recursive: true });

  let html = path.resolve(entrada);
  let tokens = null;
  let totalEsperado = null;
  const relatorio = { entrada: path.resolve(entrada), saida };

  if (ehJson) {
    const j = JSON.parse(await readFile(entrada, 'utf8'));
    validarCarrossel(j);
    totalEsperado = j.slides.length;

    let marcaPath = args.marca ? path.resolve(args.marca) : null;
    if (!marcaPath) {
      let dir = path.dirname(path.resolve(entrada));
      for (let n = 0; n < 5 && !marcaPath; n++) {
        const cand = path.join(dir, 'marca.md');
        if (existsSync(cand)) marcaPath = cand;
        const acima = path.dirname(dir);
        if (acima === dir) break;
        dir = acima;
      }
    }
    const marca = marcaPath ? lerMarca(await readFile(marcaPath, 'utf8')) : { cores: {}, fontes: {}, handle: '', dominio: '', avisos: ['marca.md nao encontrado; cores e fontes sairam do padrao'] };
    const pastasFonte = [marcaPath ? path.join(path.dirname(marcaPath), 'fonts') : null, ...args.fontes.map((p) => path.resolve(p)), FONTES_SKILL];
    tokens = await montarTokens(marca, pastasFonte, saida);
    html = await montarHtml(j, marca, saida);
    Object.assign(relatorio, { marca: marcaPath || null, handle: marca.handle || null, dominio: marca.dominio || null, cores: tokens.cores, fontes: tokens.fontes, padroes: tokens.padroes, avisos: tokens.avisos });
    console.log(`html: ${html}`);
    console.log(`marca: ${marcaPath || 'nenhum (padrao)'}`);
    console.log(`cores: fundo ${tokens.cores.fundo.valor}, destaque ${tokens.cores.destaque.valor}, claro ${tokens.cores.claro.valor}`);
    console.log(`fontes: ${tokens.familias.join(', ')} (${tokens.arquivosFonte.join(', ')})`);
    console.log(`padroes aplicados: ${tokens.padroes.length ? tokens.padroes.join('; ') : 'nenhum'}`);
    for (const a of tokens.avisos) console.log(`aviso: ${a}`);
  } else {
    // HTML pronto: as familias a conferir sao as que o proprio HTML declara em @font-face.
    const css = await readFile(html, 'utf8');
    const tokensPath = path.join(path.dirname(html), 'tokens.css');
    const extra = existsSync(tokensPath) ? await readFile(tokensPath, 'utf8') : '';
    const fam = new Set();
    for (const m of (css + extra).matchAll(/@font-face\s*\{[^}]*font-family:\s*['"]([^'"]+)['"]/g)) fam.add(m[1]);
    tokens = { familias: [...fam] };
    totalEsperado = (css.match(/class="slide[\s"]/g) || []).length || null;
  }

  if (args.soHtml) { console.log('so-html: render nao executado.'); return; }

  const r = await renderizar(html, saida, tokens.familias);
  if (r.semMotor) {
    console.log(`SEM MOTOR DE RENDER: ${r.semMotor}`);
    console.log(`O HTML esta pronto em ${html}. Para exportar sem o script: abra o arquivo no Chrome, imprima em PDF com tamanho de pagina 1080x1350 px (11.25 x 14.06 pol), margens zero e "graficos de fundo" ligado; para os PNGs, abra cada slide em 100% e capture 1080x1350, ou instale o motor com: npm i playwright && npx playwright install chromium, e rode este comando de novo.`);
    process.exit(2);
  }

  // Conferencias mecanicas no artefato, nao no processo.
  const problemas = [];
  const pngs = [];
  for (const arquivo of r.pngs) {
    const t = await tamanhoPng(arquivo);
    pngs.push({ arquivo: path.basename(arquivo), ...t });
    if (!t || t.largura !== LARGURA || t.altura !== ALTURA) problemas.push(`${path.basename(arquivo)} mede ${t ? `${t.largura}x${t.altura}` : 'invalido'}, esperado ${LARGURA}x${ALTURA}`);
  }
  if (totalEsperado != null && r.pngs.length !== totalEsperado) problemas.push(`${r.pngs.length} PNG para ${totalEsperado} slides`);
  const pdfInfo = fontesDoPdf(await readFile(r.pdf));
  if (pdfInfo.paginas !== r.pngs.length) problemas.push(`PDF com ${pdfInfo.paginas} paginas para ${r.pngs.length} slides`);
  const declaradas = tokens.familias.map(normalizar);
  const estranhas = pdfInfo.nomes.filter((n) => !declaradas.some((d) => normalizar(n).startsWith(d)));
  if (estranhas.length) problemas.push(`PDF embute fonte fora da declarada: ${estranhas.join(', ')}`);
  const ausentes = tokens.familias.filter((f) => !pdfInfo.nomes.some((n) => normalizar(n).startsWith(normalizar(f))));
  if (ausentes.length) problemas.push(`fonte declarada e ausente do PDF: ${ausentes.join(', ')}`);
  for (const a of r.ajuste) if (!a.cabe) problemas.push(`slide ${a.slide}: texto nao coube no quadro nem na escala ${a.escala}; encurte a copy no carrossel.json`);
  for (const e of r.erros) problemas.push(e);

  Object.assign(relatorio, { pngs, pdf: { arquivo: path.basename(r.pdf), paginas: pdfInfo.paginas, fontes: pdfInfo.nomes }, escala: r.ajuste, problemas });
  await writeFile(path.join(saida, 'render-relatorio.json'), JSON.stringify(relatorio, null, 2) + '\n');

  console.log(`png: ${pngs.length} arquivos, ${pngs.every((p) => p.largura === LARGURA && p.altura === ALTURA) ? `todos ${LARGURA}x${ALTURA}` : 'tamanho errado'}`);
  console.log(`pdf: ${pdfInfo.paginas} paginas, fontes embutidas: ${pdfInfo.nomes.join(', ') || 'nenhuma'}`);
  console.log(`escala por slide: ${r.ajuste.map((a) => `${String(a.slide).padStart(2, '0')}=${a.escala.toFixed(2)}${a.cabe ? '' : '!'}`).join(' ')}`);
  console.log(`relatorio: ${path.join(saida, 'render-relatorio.json')}`);
  if (problemas.length) { for (const p of problemas) console.error('FALHA: ' + p); process.exit(1); }
  console.log(`ok: ${pngs.length} slides conferidos em ${saida}. Falta olhar as imagens.`);
}

main().catch((e) => { console.error('FALHA: ' + (e.stack || e.message)); process.exit(1); });
