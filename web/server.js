// npm install express ws
const express = require("express");
const http = require("http");
const WebSocket = require("ws");

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Servir les fichiers web (index.html)
app.use(express.static("public"));

// Liste des clients connectés
let players = {}; // clientId -> { name, score }

wss.on("connection", (ws,req) => {
  console.log("✅ Nouveau client connecté");

  ws.on("message", (msg) => {
    let data = JSON.parse(msg.toString());

    // Quand un client s'identifie
    if (data.type === "identify") {
      let clientId = data.clientId;

      if (players[clientId]) {
        // Joueur déjà connu → renvoyer ses infos
        ws.send(JSON.stringify({
          type: "restore",
          player: players[clientId]
        }));
      } else {
        // Nouveau joueur → demander le login
        ws.send(JSON.stringify({ type: "needLogin" }));
      }
    }
    // Quand un joueur rejoint avec un pseudo
    else if (data.type === "join") {
      players[data.clientId] = { name: data.player, score: 0 };
      broadcast({ type: "updateScores", scores: players });
    }
    // Quand un joueur répond
    else if (data.type === "answer") {
      console.log("🕹", data.player, "→", data.answer);
      // Exemple : +1 point à chaque réponse (ajuste selon tes règles)
      players[data.clientId].score++;
      broadcast({ type: "updateScores", scores: players });
    }
  });
});

// Fonction broadcast : envoie à tous les clients connectés (dont Godot)
function broadcast(obj) {
  let msg = JSON.stringify(obj);
  wss.clients.forEach((c) => {
    if (c.readyState === WebSocket.OPEN) c.send(msg);
  });
}

const PORT = 3000;
server.listen(PORT, () => {
  console.log("🚀 Serveur lancé sur http://localhost:" + PORT);
});

function sendQuestion(questionText, answers) {
  let msg = {
    type: "question",
    text: questionText,
    answers: answers // tableau ["A", "B", "C", "D"]
  };
  broadcast(msg);
}