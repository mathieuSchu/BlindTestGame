let ws;
let clientId;
let playerName = "";

document.addEventListener("DOMContentLoaded", () => {
    // Générer un ID unique si pas déjà en mémoire
    clientId = localStorage.getItem("clientId");
    if (!clientId) {
        clientId = "client-" + Math.random().toString(36).substr(2, 9);
        localStorage.setItem("clientId", clientId);
    }

    // Connexion WebSocket
    ws = new WebSocket("ws://" + window.location.host);
    
    ws.onopen = () => {
    console.log("✅ Connecté au serveur");
    // Identification immédiate
    ws.send(JSON.stringify({ type: "identify", clientId: clientId }));
  };

  ws.onmessage = (event) => {
    let data = JSON.parse(event.data);
    console.log("📩 Message reçu:", data);

    if (data.type === "needLogin") {
      document.getElementById("login").style.display = "block";
      document.getElementById("wait").style.display = "none";
    }
    else if (data.type === "restore") {
      playerName = data.player.name;
      document.getElementById("login").style.display = "none";
      document.getElementById("wait").style.display = "block";
      updateScores({ [clientId]: data.player });
    }
    else if (data.type === "updateScores") {
      updateScores(data.scores);
    }
    else if (data.type === "question") {
      updateQuestion(data);
    }
  };
   // Bouton login
  document.getElementById("joinBtn").addEventListener("click", () => {
    playerName = document.getElementById("name").value || "Anonyme";
    ws.send(JSON.stringify({ type: "join", clientId: clientId, player: playerName }));
    document.getElementById("login").style.display = "none";
    document.getElementById("wait").style.display = "block";
  });
});


function sendAnswer(choice) {
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ type: "answer", clientId: clientId, answer: choice }));
  }
}

function updateQuestion(data) {
  document.getElementById("question").textContent = data.text;

  let btns = document.querySelectorAll("#answers button");
  data.answers.forEach((ans, i) => {
    if (btns[i]) {
      btns[i].textContent = ans;
      btns[i].setAttribute("onclick", `sendAnswer('${ans}')`);
    }
  });
}

function updateScores(scores) {
  let ul = document.getElementById("scores");
  ul.innerHTML = "";
  for (let p in scores) {
    let li = document.createElement("li");
    li.textContent = scores[p].name + " : " + scores[p].score;
    ul.appendChild(li);
  }
}