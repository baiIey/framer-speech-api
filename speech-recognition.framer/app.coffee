###
Framer Studio will likely give the error below and you may not be able to interact with your prototype's preview in the IDE.

TypeError: undefined is not a constructor (evaluating 'new SpeechRecognition')

To get around this, we'll run `python -m SimpleHTTPServer [port]` in the directory of the prototype's index.html file and use [Chrome 33 or greater] when interacting with our prototypes. (`SpeechRecognition` doesn't trigger the microphone in Framer Studio's-generated server.) 

1. Open Terminal
2. `cd` into `speech-recognition.framer`
4. Type: `python -m SimpleHTTPServer 8090`
5. In Chrome, navigate to [http://127.0.0.1:8090/](http://127.0.0.1:8090/)

This will now show the prototype in the current working directory.
###

###
Variables
###
animationDuration = 0.5
footerVisisbleY = 1240
footerHiddenY = 1400
logoVisibleY = 442
logoHiddenY = 1000

###
Layers
###
bg = new Layer # gray background image of first view
	width: Screen.width
	height: Screen.height
	image: "images/okGoogle@2x.png"

microphoneImg = new Layer # image of microphone
	width: 62 * 2
	height: 64 * 2
	y: 389 * 2
	image: "images/mic@2x.png"
microphoneImg.centerX()

microphoneBtnBg = new Layer # generated bg for microphone which scales on transition
	backgroundColor: "#fff"
	borderRadius: "50%"
	width: 62 * 2
	height: 62 * 2
	scale: 0
	y: microphoneImg.y
microphoneBtnBg.originX = 0.5
microphoneBtnBg.originY = 0.5
microphoneBtnBg.centerX()

googleLogo = new Layer # Google logo image
	width: 159 * 2
	height: 53 * 2
	opacity: 1
	y: logoVisibleY
	image: "images/googleImg@2x.png"
googleLogo.centerX()

googleLogo.states.add
	visible: # orgin of logo
		opacity: 1.0
		y: logoVisibleY
	hidden:
		opacity: 0.0 # animate and hide the logo
		y: logoHiddenY
	
textBox = new Layer # text box for speech string, hidden onload
	html: "Speak now"
	color: "#969696"
	backgroundColor: "none"
	x: 50, y: 80
	width: 660
	height: 1000
	opacity: 0.0

textBox.style = # CSS for textbox
	"fontSize" : "48px"
	"fontWeight" : "300"
	"textAlign" : "left"
	"fontFamily": "Roboto" # imported in index.html
	"lineHeight" : "55px"
	
textBox.states.add
	hidden: # hidden on start screen
		opacity: 0.0
	visible: # reveal
		opacity: 1.0
		
textBox.states.animationOptions =
	time: 0.1 # one-off animation timing
	
closeIcon = new Layer # close button for speech screen
	width: 22 * 2
	height: 22 * 2
	image: "images/closeIcon@2x.png"
	y: footerHiddenY
closeIcon.x = closeIcon.width * 1.25

closeIcon.states.add
	hidden:
		y: footerHiddenY
	visible: 
		y: footerVisisbleY

webIcon = new Layer # web icon on speech screen
	width: 28 * 2
	height: 28 * 2
	image: "images/webIcon@2x.png"
	y: footerHiddenY
webIcon.x = Screen.width - webIcon.width * 1.9

webIcon.states.add
	hidden:
		y: footerHiddenY
	visible: 
		y: footerVisisbleY - 5
	
###
GIF Layers
###
gDots = new VideoLayer # restful animating
	width: 360
	height: 203
	image: "images/g-dots-360-1.gif"
	y: googleLogo.y - 50
	opacity: 0
	backgroundColor: "white"
gDots.centerX()

gDots.states.add #animate and reveal animation with logo
	visible:
		opacity: 1.0
		y: logoHiddenY - 50
	hidden:
		opacity: 0.0
		y: logoVisibleY - 50
	invisible:
		opacity: 0

gDotSpeech = new Layer #thinking animation for speech recognizer
	width: 666 / 2
	height: 270 / 2
	image: "images/gDotSpeech.gif"
	y: logoHiddenY - 50
	opacity: 0
gDotSpeech.centerX()

gDotSpeech.states.add
	visible:
		opacity: 1
	hidden:
		opacity: 0

###
Speech API
###
# This API is currently prefixed in Chrome
SpeechRecognition = window.SpeechRecognition or window.webkitSpeechRecognition

# Create a new recognizer
recognizer = new SpeechRecognition

# Start producing results before the person has finished speaking
recognizer.interimResults = true

# Set the language of the recognizer
recognizer.lang = 'en-US'

# Define a callback to process results
recognizer.onresult = (event) ->
  result = event.results[event.resultIndex]
  if result.isFinal
    #print 'You said: ' + result[0].transcript
    textBox.html = result[0].transcript
  else
    #print 'Interim result', result[0].transcript
    textBox.html = result[0].transcript
  return

# update graphic on speech start
recognizer.onspeechstart = (event) ->
	#print "Speech start"
	gDots.states.switch("invisible", time: animationDuration)
	gDotSpeech.states.switch("visible", time: animationDuration)

# update graphic on speech end
recognizer.onspeechend = (event) ->
	#print "Speech end"
	gDots.states.switch("visible", time: animationDuration)
	gDotSpeech.states.switch("hidden", time: animationDuration)
	
###
Events
###
# Start listening...
microphoneImg.on Events.Click, ->
	recognizer.start()
	#print "clicked"
	microphoneBtnBg.animate
		properties: 
			scale: 17.0	
		time: animationDuration
	webIcon.states.switch("visible")
	closeIcon.states.switch("visible")
	textBox.states.switch("visible", time: 0.5)
	googleLogo.states.switch("hidden", time: animationDuration)
	gDots.states.switch("visible", time: animationDuration)

closeIcon.on Events.Click, ->
	recognizer.stop()
	Utils.delay 0.5, ->
		textBox.html = "Speak now"
	#print "close button did press"
	microphoneBtnBg.animate
		properties: 
			scale: 0.0	
		time: animationDuration
	webIcon.states.switch("hidden")
	closeIcon.states.switch("hidden")
	textBox.states.switch("hidden", time: 0.1)
	googleLogo.states.switch("visible", time: animationDuration)
	gDots.states.switch("hidden", time: animationDuration)
