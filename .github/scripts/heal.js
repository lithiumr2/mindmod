const fs = require('fs');
const { execSync } = require('child_process');

async function run() {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.log("No GEMINI_API_KEY secret found. Skip auto-heal.");
    process.exit(0);
  }

  // Verificar límite de 3 intentos leyendo el último commit
  const lastCommitMsg = execSync('git log -1 --pretty=%B').toString();
  const attemptMatch = lastCommitMsg.match(/\[Auto-Fix Intento (\d+)\]/);
  let attempt = 1;
  if (attemptMatch) {
    attempt = parseInt(attemptMatch[1], 10) + 1;
    if (attempt > 3) {
      console.log("Límite máximo de auto-reparación (3 intentos) alcanzado. Deteniendo para evitar bucle infinito.");
      process.exit(0);
    }
  }

  const errorLog = fs.existsSync('error.log') ? fs.readFileSync('error.log', 'utf8') : "";
  if (!errorLog || errorLog.includes("No logs found")) {
    console.log("No error log available.");
    process.exit(0);
  }

  // Buscar todos los archivos .dart mencionados en el log de error
  const fileRegex = /lib\/[\w\/\.]+\.dart/g;
  const mentionedFiles = [...new Set([...errorLog.matchAll(fileRegex)].map(m => m[0]))];

  let filesContent = "";
  if (mentionedFiles.length > 0) {
    for (const file of mentionedFiles) {
      if (fs.existsSync(file)) {
        filesContent += `\n--- Archivo: ${file} ---\n${fs.readFileSync(file, 'utf8')}\n`;
      }
    }
  } else {
    filesContent = "No se detectaron rutas de archivos específicas en el log de errores.";
  }

  const prompt = `
  Eres un bot de auto-reparación integrado directamente en GitHub Actions. La compilación de este código Flutter acaba de fallar.
  Tu trabajo es arreglar el error sin alterar las funcionalidades existentes de la aplicación.
  
  LOG DE ERROR (Últimas líneas del fallo de compilación):
  ${errorLog.substring(0, 4000)}

  CÓDIGO DE LOS ARCHIVOS INVOLUCRADOS:
  ${filesContent.substring(0, 15000)}

  Reglas de respuesta:
  1. No devuelvas NADA MÁS que un objeto JSON válido, sin bloques de código markdown, sin explicaciones. Solo el JSON puro.
  2. En el 'commit_description', escribe claramente qué fue lo que falló originalmente y cómo lo arreglaste, para que el humano pueda leerlo en el historial de git.
  3. Devuelve el archivo completo con las correcciones aplicadas en 'content'.
  
  ESTRUCTURA JSON REQUERIDA:
  {
    "commit_title": "fix: [breve titulo del arreglo]",
    "commit_description": "[Explicación técnica del error y cómo se solucionó]",
    "files": [
      {
        "path": "lib/ruta/al/archivo.dart",
        "content": "[código completo corregido]"
      }
    ]
  }
  `;

  try {
        const models = ["gemini-3.6-flash", "gemini-2.5-flash", "gemini-1.5-flash"];
    let data = null;
    for (const model of models) {
      try {
        console.log(`Trying Gemini model: ${model}...`);
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: { response_mime_type: "application/json" }
          })
        });
        const resJson = await response.json();
        if (!resJson.error) {
          data = resJson;
          console.log(`Model ${model} succeeded!`);
          break;
        } else {
          console.warn(`Model ${model} returned error:`, resJson.error.message);
        }
      } catch (err) {
        console.warn(`Failed with ${model}:`, err.message);
      }
    }

    if (!data || !data.candidates || data.candidates.length === 0) {
      console.error("No valid response from any Gemini model.");
      process.exit(1);
    }

    const rawText = data.candidates[0].content.parts[0].text;
    const result = JSON.parse(rawText);

    if (result.files && result.files.length > 0) {
      for (const file of result.files) {
        // Asegurar que el directorio exista si es necesario
        const dir = file.path.split('/').slice(0, -1).join('/');
        if (dir) fs.mkdirSync(dir, { recursive: true });
        
        fs.writeFileSync(file.path, file.content);
        console.log(`Arreglado: ${file.path}`);
      }

      const finalCommitMsg = `${result.commit_title} [Auto-Fix Intento ${attempt}]\n\nCausa del fallo:\n${result.commit_description}`;
      fs.writeFileSync('commit_msg.txt', finalCommitMsg);
      console.log("Corrección generada exitosamente.");
    } else {
      console.log("No se devolvieron archivos para modificar.");
    }
  } catch (e) {
    console.error("Fallo al contactar la API de IA o parsear la respuesta:", e);
    process.exit(1);
  }
}

run();
