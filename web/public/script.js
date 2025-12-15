let ws;
let clientId;
let playerName = "";
let hasAnsweredCurrentQuestion = false;
const availableAvatars = ['🎵', '🎤', '🎧', '😎', '🎸', '🥁', '🎷', '🎹'];
let currentAvatarIndex = 0;

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
      showState("login");
    }
    else if (data.type === "restore") {
      playerName = data.player.name;
      playericoneid = data.player.icone;
      state=data.player.personal_state.type;
      // TODO: Mettre à jour l'affichage de l'avatar/pseudo si besoin
      updateHeaderDispay(playerName,playericoneid);
      if (state == "wait"){
        showState("wait");
      }
      else if (state == "question"){
        showState("game3");
        initializeNewRound(data.player.personal_state.value,"Répondez vite");
      }
      else if (state == "selection"){
        showState("game3");
        initializeNewRound(data.player.personal_state.value,"Selection de la manche");
      }
    }
    else if (data.type === "question") {
      showState("game3");
      initializeNewRound(data.numChoices,"Répondez vite");
    }
    else if (data.type === "selection") {
        if(data.id === clientId)
      showState("game3");
      initializeNewRound(data.numChoices,"Selection de la manche");
    }
    else if (data.type === "wait") {
      showState("wait");
    }
  };
   // Bouton login
  setupAvatarChooser();
  document.getElementById("joinBtn").addEventListener("click", () => {
        playerName = document.getElementById("name").value || "Anonyme"; 
        // 🔑 NOUVEAU: Récupérer l'index (ID) de l'avatar choisi
        const selectedIconId = currentAvatarIndex; 
        

        // 🔑 ENVOI DE L'AVATAR AU SERVEUR (vous envoyez l'index 'icone')
        ws.send(JSON.stringify({ 
            type: "join", 
            clientId: clientId, 
            player: playerName, 
            icone: selectedIconId 
        })); 
        updateHeaderDispay(playerName,selectedIconId)
        showState("wait");
    });

});

function updateHeaderDispay(playerName,iconeid){
        const selectedIconText = availableAvatars[iconeid];
        const headerAvatarDisplay = document.getElementById('avatar-display');
        const headerDisplay = document.getElementById('header-display'); // Référence au header complet
        const pseudoDisplay = document.getElementById('pseudo-display');
        // Mettre à jour l'affichage de l'avatar dans le header (pour quand l'état "wait" s'active)
        pseudoDisplay.textContent = playerName;
        // L'icône est déjà mise à jour via updateAvatarDisplay()
        headerDisplay.style.display = 'flex';
        headerAvatarDisplay.textContent = selectedIconText; 
}


function showState(state) {
    // Cache tous les conteneurs d'état de jeu
    document.getElementById("login").style.display = "none";
    document.getElementById("wait").style.display = "none";
    
    // Si votre HTML utilise d'autres IDs pour les jeux, ajustez ici
    // document.getElementById("game1").style.display = "none"; 
    // document.getElementById("game2").style.display = "none"; 
    document.getElementById("game3").style.display = "none";

    // Affiche l'état demandé
    document.getElementById(state).style.display = "block";
}

/**
 * Envoie la réponse au serveur si le joueur n'a pas déjà répondu.
 * @param {string} choice - Le texte de l'option de réponse choisie.
 */

function sendAnswer(choice) {
  if (ws && ws.readyState === WebSocket.OPEN && !hasAnsweredCurrentQuestion) 
  {
    const reactionTimeMs = Date.now() - questionStartTime;
    ws.send(JSON.stringify({ type: "answer", clientId: clientId, answer: choice,time :0}));
  }
}

function initializeNewRound(numChoices,text_question) {
    // 1. Réinitialise le temps de réponse et le drapeau de blocage
    enableAllAnswers();

    // 2. Met à jour le texte de la question (si vous voulez juste un message générique)
    document.getElementById("question").textContent = text_question;

    const answersContainer = document.getElementById("answers");
    answersContainer.innerHTML = ''; 
    
    // Déterminer les lettres de A à D
    const choices = ['A', 'B', 'C', 'D'];

    // 3. Créer dynamiquement les boutons A, B, C, D
    for (let i = 0; i < numChoices && i < 4; i++) {
        const choiceLetter = choices[i];
        const choiceId = i; // 0 (A), 1 (B), 2 (C), etc.

        const button = document.createElement('button');
        button.textContent = choiceLetter; // Affiche la lettre
        
        // Ajouter l'événement de clic
        button.addEventListener('click', (e) => {
            // 1. Envoi au serveur (avec l'ID et le temps)
            sendAnswer(choiceId);
            // 2. Blocage local
            blockAnswers(e.currentTarget);
        });
        answersContainer.appendChild(button);
    }
}


function blockAnswers(chosenButton) {
    if (hasAnsweredCurrentQuestion) return;
    hasAnsweredCurrentQuestion = true;
    
    document.querySelectorAll("#answers button").forEach(btn => {
        btn.disabled = true; 
    });

    // Marque le bouton choisi pour le style (nécessite le CSS 'chosen')
    chosenButton.classList.add('chosen');
}

function enableAllAnswers() {
    hasAnsweredCurrentQuestion = false;
    questionStartTime = null; // Réinitialise le temps de début
    document.querySelectorAll("#answers button").forEach(btn => {
        btn.disabled = false;
        btn.classList.remove('chosen'); 
    });
}

function setupAvatarChooser() {
    const prevButton = document.getElementById('avatar-prev');
    const nextButton = document.getElementById('avatar-next');
    const iconDisplay = document.getElementById('current-avatar-icon');
    const headerAvatarDisplay = document.getElementById('avatar-display');

    function updateAvatarDisplay() {
        const selectedIconText = availableAvatars[currentAvatarIndex];
        iconDisplay.textContent = selectedIconText;
        // Met à jour l'icône dans la zone d'affichage supérieure
        headerAvatarDisplay.textContent = selectedIconText; 
    }
    // Initialiser l'affichage
    updateAvatarDisplay();

    // Gérer l'icône suivante
    nextButton.addEventListener('click', () => {
        currentAvatarIndex = (currentAvatarIndex + 1) % availableAvatars.length;
        updateAvatarDisplay();
    });

    // Gérer l'icône précédente
    prevButton.addEventListener('click', () => {
        currentAvatarIndex = (currentAvatarIndex - 1 + availableAvatars.length) % availableAvatars.length;
        updateAvatarDisplay();
    });
}

document.addEventListener("visibilitychange", function () {
    if (!document.hidden) {
        // La page redevient visible → refresh
        location.reload();
    }
});