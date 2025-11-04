// Chrome's implementation of `SpeechRecognition` will not trigger inside the Framer
// Studio preview server. Serve this prototype with `python3 -m http.server 8090`
// from the project directory and open it in Chrome 33+ to interact with the mic.

const animationDuration = 0.5;
const footerVisisbleY = 1240;
const footerHiddenY = 1400;
const logoVisibleY = 442;
const logoHiddenY = 1000;

const bg = new Layer({
	width: Screen.width,
	height: Screen.height,
	image: "images/okGoogle@2x.png",
});

const microphoneImg = new Layer({
	width: 62 * 2,
	height: 64 * 2,
	y: 389 * 2,
	image: "images/mic@2x.png",
});
microphoneImg.centerX();

const microphoneBtnBg = new Layer({
	backgroundColor: "#fff",
	borderRadius: "50%",
	width: 62 * 2,
	height: 62 * 2,
	scale: 0,
	y: microphoneImg.y,
});
microphoneBtnBg.originX = 0.5;
microphoneBtnBg.originY = 0.5;
microphoneBtnBg.centerX();

const googleLogo = new Layer({
	width: 159 * 2,
	height: 53 * 2,
	opacity: 1,
	y: logoVisibleY,
	image: "images/googleImg@2x.png",
});
googleLogo.centerX();

googleLogo.states.add({
	visible: {
		opacity: 1,
		y: logoVisibleY,
	},
	hidden: {
		opacity: 0,
		y: logoHiddenY,
	},
});

const textBox = new Layer({
	html: "Speak now",
	color: "#969696",
	backgroundColor: "none",
	x: 50,
	y: 80,
	width: 660,
	height: 1000,
	opacity: 0,
});

textBox.style = {
	fontSize: "48px",
	fontWeight: "300",
	textAlign: "left",
	fontFamily: "Roboto",
	lineHeight: "55px",
};

textBox.states.add({
	hidden: {
		opacity: 0,
	},
	visible: {
		opacity: 1,
	},
});

textBox.states.animationOptions = {
	time: 0.1,
};

const closeIcon = new Layer({
	width: 22 * 2,
	height: 22 * 2,
	image: "images/closeIcon@2x.png",
	y: footerHiddenY,
});
closeIcon.x = closeIcon.width * 1.25;

closeIcon.states.add({
	hidden: {
		y: footerHiddenY,
	},
	visible: {
		y: footerVisisbleY,
	},
});

const webIcon = new Layer({
	width: 28 * 2,
	height: 28 * 2,
	image: "images/webIcon@2x.png",
	y: footerHiddenY,
});
webIcon.x = Screen.width - webIcon.width * 1.9;

webIcon.states.add({
	hidden: {
		y: footerHiddenY,
	},
	visible: {
		y: footerVisisbleY - 5,
	},
});

const gDots = new VideoLayer({
	width: 360,
	height: 203,
	image: "images/g-dots-360-1.gif",
	y: googleLogo.y - 50,
	opacity: 0,
	backgroundColor: "white",
});
gDots.centerX();

gDots.states.add({
	visible: {
		opacity: 1,
		y: logoHiddenY - 50,
	},
	hidden: {
		opacity: 0,
		y: logoVisibleY - 50,
	},
	invisible: {
		opacity: 0,
	},
});

const gDotSpeech = new Layer({
	width: 666 / 2,
	height: 270 / 2,
	image: "images/gDotSpeech.gif",
	y: logoHiddenY - 50,
	opacity: 0,
});
gDotSpeech.centerX();

gDotSpeech.states.add({
	visible: {
		opacity: 1,
	},
	hidden: {
		opacity: 0,
	},
});

const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
let recognizer = null;

if (typeof SpeechRecognition === "function") {
	recognizer = new SpeechRecognition();
	recognizer.interimResults = true;
	recognizer.lang = "en-US";

	recognizer.onresult = event => {
		const result = event.results[event.resultIndex];
		if (!result || !result[0]) return;
		textBox.html = result[0].transcript;
	};

	recognizer.onspeechstart = () => {
		gDots.states.switch("invisible", { time: animationDuration });
		gDotSpeech.states.switch("visible", { time: animationDuration });
	};

	recognizer.onspeechend = () => {
		gDots.states.switch("visible", { time: animationDuration });
		gDotSpeech.states.switch("hidden", { time: animationDuration });
	};
} else {
	console.warn("SpeechRecognition API is not available in this browser.");
}

microphoneImg.on(Events.Click, () => {
	if (!recognizer) return;

	recognizer.start();

	microphoneBtnBg.animate({
		properties: {
			scale: 17,
		},
		time: animationDuration,
	});

	webIcon.states.switch("visible");
	closeIcon.states.switch("visible");
	textBox.states.switch("visible", { time: 0.5 });
	googleLogo.states.switch("hidden", { time: animationDuration });
	gDots.states.switch("visible", { time: animationDuration });
});

closeIcon.on(Events.Click, () => {
	if (!recognizer) return;

	recognizer.stop();
	Utils.delay(0.5, () => {
		textBox.html = "Speak now";
	});

	microphoneBtnBg.animate({
		properties: {
			scale: 0,
		},
		time: animationDuration,
	});

	webIcon.states.switch("hidden");
	closeIcon.states.switch("hidden");
	textBox.states.switch("hidden", { time: 0.1 });
	googleLogo.states.switch("visible", { time: animationDuration });
	gDots.states.switch("hidden", { time: animationDuration });
});
