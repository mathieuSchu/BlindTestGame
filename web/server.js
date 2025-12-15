// ---------------------------
//  IMPORTS
// ---------------------------
const express = require("express");
const http = require("http");
const WebSocket = require("ws");

const app = express();
const server = http.createServer(app);


// ---------------------------
//  SERVEUR WEB → joueurs
// --------------------------
const wss_player = new WebSocket.Server({ server });
// ---------------------------
//  SERVEUR GODOT → port 8081
// ---------------------------
let godot = null;
const ws_godot = new WebSocket("ws://localhost:8081");

// ---------------------------
//  ETAT GLOBAL DU JEU
// ---------------------------
let GAME_STATE = "lobby"; 
// lobby  → inscriptions ouvertes
// selection → inscriptions fermées
// question → question en cours
// results → fin de manche




// Connexion au serveur WebSocket de Godot
ws_godot.on("open", () => {
    console.log("🎮 Connecté à Godot !");
    godot = ws_godot;
});

ws_godot.on("message", msg => {
    let data = JSON.parse(msg.toString());
    console.log("📩 Message Godot:", data);

    // ----------- Godot change l'état du jeu -----------
    if (data.type === "setState") {
        GAME_STATE = data.state;
        console.log("🔄 STATE changé par Godot :", GAME_STATE);
        if (GAME_STATE == "end"){
          server.close;
          close;
        }
    }
    // ----------- Godot envoie une question -----------
    else if (data.type === "question") {
        console.log("Question");
        for (const key of Object.keys(players)) {
        players[key].personal_state.type= "question";
        players[key].personal_state.value= data.numChoices;
        }
        broadcast(data);
    }
    // ----------- Godot demande une selection -----------
    else if (data.type === "selection"){
      console.log("Selection");
      players[data.id].personal_state.type = "selection";
      players[data.id].personal_state.value= data.numChoices;
      broadcast(data);
    }
    // ----------- Godot demande une atente -----------
    else if (data.type === "wait"){
      console.log("wait");
      for (const key of Object.keys(players)) {
        players[key].personal_state.type= "wait";
      }
      broadcast(data);
    }
});
ws_godot.on("close", () => {
    console.log("❌ Godot déconnecté");
});
ws_godot.on("error", err => {
    console.log("⚠ Erreur Godot:", err);
});

// ---------------------------
//  FICHIERS WEB
// ---------------------------
app.use(express.static("public"));

// ---------------------------
//  GESTION DES JOUEURS
// ---------------------------
let players = {}; // clientId -> { name,icone,personal_state{wait,question,selection}}
let sockets = {}; // websocket -> {clientId  }

wss_player.on("connection", (ws,req) => {
  console.log("✅ Un joueur s'est connecté");

  ws.on("message", (msg) => {
    let data = JSON.parse(msg.toString());

    // ------------- IDENTIFICATION -------------
    if (data.type === "identify") {
      let id = data.clientId;
      sockets[ws] = id;
      if (players[id]) {
        // Joueur déjà connu → renvoyer ses infos
        ws.send(JSON.stringify({
          type: "restore",
          player: players[id] 
        }));
        console.log("Joueur reconnu  :",players[id].name,"Stat",players[id].personal_state.type);
        //sendToGodot({type: "join",id: data.clientId,player:players[id]});
      } else {
        // Nouveau joueur
        if (GAME_STATE !== "lobby")
        {
            ws.send(JSON.stringify({
                        type: "cantJoin"
                    }));
            console.log("⛔ Nouveau joueur refusé (jeu en cours)");
        }
        else{
        ws.send(JSON.stringify({ type: "needLogin" }));
        console.log("🆕 Nouveau joueur détecté");
        }
      }
    }
    // ------------- LOGIN -------------
    else if (data.type === "join") 
    {
      if (GAME_STATE !=="lobby")
      {
          ws.send(JSON.stringify({
                        type: "cantJoin"
                    }));
          console.log("⛔ Nouveau joueur refusé (jeu en cours)");
      }
      else
      {
        players[data.clientId] = { name: data.player, icone: data.icone , personal_state: {type :"wait",value : 0}};
        console.log("📝 Inscription joueur : ",players[data.clientId].name,"; icone : ",players[data.clientId].icone);
        sendToGodot({type: "join",id: data.clientId,player:players[data.clientId]});
      }
      
    }

    // ------------- RÉPONSE DU JOUEUR -------------
    else if (data.type === "answer") {
      let id = data.clientId;
      let answer = data.answer;
      let time = data.time;
      players[id].personal_state.type = "wait";
      console.log("Réponce du joueur ",id,"; réponse : ",answer);
      sendToGodot({type: "playerAnswer",id: id,answer: answer,time:time});
    }
  });

  ws.on("close", () => {
    let id = sockets[ws]
    console.log("🔴 Joueur déconnecté : ",id);
    if(GAME_STATE === "lobby")
    {
      delete players[id]
      sendToGodot({type: "leave",id: id});
    }
  });
});

// ---------------------------
//  BROADCAST AUX JOUEURS
// ---------------------------
function broadcast(obj) {
  let msg = JSON.stringify(obj);
  wss_player.clients.forEach(client  => {
    if (client.readyState === WebSocket.OPEN) client.send(msg);
  });
}

// ---------------------------
//  ENVOYER À GODOT
// ---------------------------
function sendToGodot(obj) {
    if (godot && godot.readyState === WebSocket.OPEN) {
        godot.send(JSON.stringify(obj));
    } else {
        console.log("⚠ Impossible d'envoyer à Godot : socket fermée");
    }
}

function sendQuestion(questionText, answers) {
  let msg = {
    type: "question",
    answers: answers // tableau ["A", "B", "C", "D"]
  };
  broadcast(msg);
}
// ---------------------------
//  LANCER SERVEUR
// ---------------------------
const PORT = 3000;
server.listen(PORT, () => {
  console.log("🚀 Serveur lancé sur http://localhost:" + PORT);
});

