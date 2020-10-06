
class ADS1299SettingsController {
    private PApplet _parentApplet;
    private boolean isVisible = false;
    private int x, y, w, h;
    private final int padding_3 = 3;
    private final int navH = 22;

    private ControlP5 hwsCp5;
    private final int numControlButtons = 3;
    private Button loadButton;
    private Button saveButton;
    private Button sendButton;
    private int button_w = 80;
    private int button_h = navH;
    private final int columnLabelH = navH + (padding_3 * 2);
    private int chanBar_h;

    private int spaceBetweenButtons = 5; //space between buttons

    private TextBox gainLabel;
    private TextBox inputTypeLabel;
    private TextBox biasLabel;
    private TextBox srb2Label;
    private TextBox srb1Label;

    private ScrollableList[] gainLists;
    private ScrollableList[] inputTypeLists;
    private ScrollableList[] biasLists;
    private ScrollableList[] srb2Lists;
    private ScrollableList[] srb1Lists;
    private boolean[] hasUnappliedChanges;

    private ADS1299Settings boardSettings;

    private int channelCount;
    private List<Integer> activeChannels;

    ADS1299SettingsController(PApplet _parent, List<Integer> _activeChannels, int _x, int _y, int _w, int _h, int _channelBarHeight) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        chanBar_h = _channelBarHeight;
        
        _parentApplet = _parent;
        hwsCp5 = new ControlP5(_parentApplet);
        hwsCp5.setGraphics(_parentApplet, 0,0);
        hwsCp5.setAutoDraw(false);
        
        int colOffset = (w / numControlButtons) / 2;
        int button_y = y - button_h - padding_3;
        createHWSettingsLoadButton("HardwareSettingsLoad", "Load", x + colOffset - button_w/2, button_y, button_w, button_h);
        createHWSettingsSaveButton("HardwareSettingsSave", "Save", x + colOffset + (w/numControlButtons) - button_w/2, button_y, button_w, button_h);
        createHWSettingsSendButton("HardwareSettingsSend", "Send", x + colOffset + (w/numControlButtons)*2 - button_w/2, button_y, button_w, button_h);

        activeChannels = _activeChannels;
        ADS1299SettingsBoard settingsBoard = (ADS1299SettingsBoard)currentBoard;
        boardSettings = settingsBoard.getADS1299Settings();
        boardSettings.saveAllLastValues();
        channelCount = currentBoard.getNumEXGChannels();
        hasUnappliedChanges = new boolean[channelCount];
        Arrays.fill(hasUnappliedChanges, Boolean.FALSE);

        color labelBG = color(220);
        color labelTxt = bgColor;
        colOffset = (w / 5) / 2;
        int label_y = y + h - navH + padding_3;
        gainLabel = new TextBox("PGA Gain", x + colOffset, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        inputTypeLabel = new TextBox("Input Type", x + colOffset + (w/5), label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        biasLabel = new TextBox("Bias Include", x + colOffset + (w/5)*2, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        srb2Label = new TextBox("SRB2", x + colOffset + (w/5)*3, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);
        srb1Label = new TextBox("SRB1", x + colOffset + (w/5)*4, label_y, labelTxt, labelBG, 12, h5, CENTER, TOP);

        createAllDropdowns(chanBar_h);
    }

    public void update() {
  
    }

    public void draw() {

        if (isVisible) {
            //Control button space above channels
            pushStyle();
            stroke(31,69,110, 50);
            fill(0, 0, 0, 100);
            rect(x, y - columnLabelH, w, columnLabelH);

            //background
            pushStyle();
            noStroke();
            fill(0, 0, 0, 100);
            rect(x, y, w, h);

            gainLabel.draw();
            inputTypeLabel.draw();
            biasLabel.draw();
            srb2Label.draw();
            srb1Label.draw();

            for (int i = 0; i < channelCount; i++) {
                boolean b = activeChannels.contains(i);
                gainLists[i].setVisible(b);
                inputTypeLists[i].setVisible(b);
                biasLists[i].setVisible(b);
                srb2Lists[i].setVisible(b);
                srb1Lists[i].setVisible(b);

                if (hasUnappliedChanges[i]) {
                    pushStyle();
                    fill(color(57, 128, 204, 190)); //light blue from TopNav
                    //fill(color(245, 64, 64, 180)); //light red
                    rect(x, y + chanBar_h * i, w, chanBar_h);
                }
            }

            //Draw cp5 objects on top of everything
            hwsCp5.draw();
        }

        popStyle();
    }

    private void resizeDropdowns(int _channelBarHeight) {
        int dropdownX = 0;
        int dropdownY = 0;
        int dropdownW = int((w - (spaceBetweenButtons*6)) / 5);
        int dropdownH = 18;

        int rowCount = 0;
        for (int i : activeChannels) {
            dropdownX = x + spaceBetweenButtons;
            dropdownY = int(y + ((_channelBarHeight)*rowCount) + (((_channelBarHeight)-dropdownH)/2));
            final int buttonXIncrement = spaceBetweenButtons + dropdownW;

            gainLists[i].setPosition(dropdownX, dropdownY);
            gainLists[i].setSize(dropdownW,5*dropdownH); //Only enough space for SelectedItem + 4 options in the latter channels
            
            dropdownX += buttonXIncrement;
            inputTypeLists[i].setPosition(dropdownX, dropdownY);
            inputTypeLists[i].setSize(dropdownW,5*dropdownH); //Only enough space for SelectedItem + 4 options in the latter channels

            dropdownX += buttonXIncrement;
            biasLists[i].setPosition(dropdownX, dropdownY);
            biasLists[i].setSize(dropdownW,(biasLists[i].getItems().size()+1)*dropdownH);

            dropdownX += buttonXIncrement;
            srb2Lists[i].setPosition(dropdownX, dropdownY);
            srb2Lists[i].setSize(dropdownW,(srb2Lists[i].getItems().size()+1)*dropdownH);

            dropdownX += buttonXIncrement;
            srb1Lists[i].setPosition(dropdownX, dropdownY);
            srb1Lists[i].setSize(dropdownW,(srb1Lists[i].getItems().size()+1)*dropdownH);

            rowCount++;
        }
    }

    public void resize(int _x, int _y, int _w, int _h, int _channelBarHeight) {
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        chanBar_h = _channelBarHeight;

        hwsCp5.setGraphics(_parentApplet, 0, 0);

        int colOffset = (w / numControlButtons) / 2;
        int button_y = y - button_h - padding_3;
        loadButton.setPosition(x + colOffset - button_w/2, button_y);
        saveButton.setPosition(x + colOffset + (w/numControlButtons) - button_w/2, button_y);
        sendButton.setPosition(x + colOffset + (w/numControlButtons)*2 - button_w/2, button_y);

        colOffset = (w / 5) / 2;
        int label_y = y + h - navH + padding_3;
        gainLabel.setPosition(x + colOffset, label_y);
        inputTypeLabel.setPosition(x + colOffset + (w/5), label_y);
        biasLabel.setPosition(x + colOffset + (w/5)*2, label_y);
        srb2Label.setPosition(x + colOffset + (w/5)*3, label_y);
        srb1Label.setPosition(x + colOffset + (w/5)*4, label_y);

        resizeDropdowns(chanBar_h);
    }

    public void setIsVisible (boolean v) {
        
        //Check if there are unapplied settings when trying to close Hardware Settings Controller
        if (!v) {
            boolean allChannelsInSync = true;

            for (int i = 0; i < hasUnappliedChanges.length; i++) {
                if (hasUnappliedChanges[i]) {
                    allChannelsInSync = false;
                }
            }

            if (!allChannelsInSync) {
                PopupMessage msg = new PopupMessage("Info", "Highlighted channels have unapplied Hardware Settings. Please press \"Send\" button to sync with board or revert settings.");
                return;
            }
        }

        isVisible = v;
    }

    public boolean getIsVisible() {
        return isVisible;
    }

    private Button createButton(Button myButton, String name, String text, int _x, int _y, int _w, int _h) {
        myButton = hwsCp5.addButton(name)
            .setPosition(_x, _y)
            .setSize(_w, _h)
            .setColorLabel(bgColor)
            .setColorForeground(color(177, 184, 193))
            .setColorBackground(colorNotPressed)
            .setColorActive(color(150,170,200))
            ;
        myButton
            .getCaptionLabel()
            .setFont(createFont("Arial",12,true))
            .toUpperCase(false)
            .setSize(12)
            .setText(text)
            ;
        return myButton;
    }

    private void createHWSettingsLoadButton(String name, String text, int _x, int _y, int _w, int _h) {
        loadButton = createButton(loadButton, name, text, _x, _y, _w, _h);
        loadButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (isRunning) {
                    PopupMessage msg = new PopupMessage("Info", "Streaming needs to be stopped before loading hardware settings.");
                } else {
                    selectInput("Select settings file to load", "loadHardwareSettings");
                }
            }
        });
    }

    private void createHWSettingsSaveButton(String name, String text, int _x, int _y, int _w, int _h) {
        saveButton = createButton(saveButton, name, text, _x, _y, _w, _h);
        saveButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                selectOutput("Save settings to file", "storeHardwareSettings");
            }
        });
    }

    private void createHWSettingsSendButton(String name, String text, int _x, int _y, int _w, int _h) {
        sendButton = createButton(sendButton, name, text, _x, _y, _w, _h);
        sendButton.onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                
                boolean[] sendCommandSuccess = ((ADS1299SettingsBoard)currentBoard).getADS1299Settings().commitAll();
                boolean noErrors = true;

                for (int i = 0; i < sendCommandSuccess.length; i++) {
                    if (!sendCommandSuccess[i]) {
                        noErrors = false;
                    } else {
                        hasUnappliedChanges[i] = false;
                        boardSettings.saveLastValues(i);
                    }
                }

                if (noErrors) {
                    output("Hardware Settings sent to board!");
                } else {
                    PopupMessage msg = new PopupMessage("Error", "Failed to send one or more Hardware Settings to board. Check hardware and battery level. Cyton users, check that your dongle is connected with blue light shining.");
                }         
            }
        });
    }

    private ScrollableList createDropdown(int chanNum, String name, ADSSettingsEnum[] enumValues, ADSSettingsEnum e) {
        int dropdownW = int((w - (spaceBetweenButtons*6)) / 5);
        int dropdownH = 18;
        ScrollableList list = new CustomScrollableList(hwsCp5, name)
            .setOpen(false)
            .setColorBackground((int)channelColors[chanNum%8]) // text field bg color
            .setColorValueLabel(color(255))       // text color
            .setColorCaptionLabel(color(255))
            .setColorForeground(color(125))    // border color when not selected
            .setColorActive(color(150, 170, 200))       // border color when selected
            .setBackgroundColor(150)
            .setSize(dropdownW, dropdownH)//temporary size
            .setBarHeight(dropdownH) //height of top/primary bar
            .setItemHeight(dropdownH) //height of all item/dropdown bars
            .setVisible(true)
            ;
        // for each entry in the enum, add it to the dropdown.
        for (ADSSettingsEnum value : enumValues) {
            // this will store the *actual* enum object inside the dropdown!
            list.addItem(value.getName(), value);
        }
        //Style the text in the ScrollableList
        list.getCaptionLabel() //the caption label is the text object in the primary bar
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getName())
            .setFont(h5)
            .setSize(12)
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(4)
            ;
        list.getValueLabel() //the value label is connected to the text objects in the dropdown item bars
            .toUpperCase(false) //DO NOT AUTOSET TO UPPERCASE!!!
            .setText(e.getName())
            .setFont(p6)
            .setSize(10) //set the font size of the item bars to 14pt
            .getStyle() //need to grab style before affecting the paddingTop
            .setPaddingTop(3) //4-pixel vertical offset to center text
            ;
        list.addCallback(new SLCallbackListener(chanNum));
        return list;
    }

    private void createAllDropdowns(int _channelBarHeight) {
        //the size and space of these buttons are dependendant on the size of the screen and full ChannelController
        verbosePrint("ChannelController: createChannelSettingButtons: creating channel setting buttons...");

        gainLists = new ScrollableList[channelCount];
        inputTypeLists = new ScrollableList[channelCount];
        biasLists = new ScrollableList[channelCount];
        srb2Lists = new ScrollableList[channelCount];
        srb1Lists = new ScrollableList[channelCount];

        //Init dropdowns in reverse so that chan 1 draws on top of chan 2, etc.
        for (int i = channelCount - 1; i >= 0; i--) {
            gainLists[i] = createDropdown(i, "gain_ch_"+(i+1), boardSettings.values.gain[i].values(), boardSettings.values.gain[i]);
            inputTypeLists[i] = createDropdown(i, "inputType_ch_"+(i+1), boardSettings.values.inputType[i].values(), boardSettings.values.inputType[i]);
            biasLists[i] = createDropdown(i, "bias_ch_"+(i+1), boardSettings.values.bias[i].values(), boardSettings.values.bias[i]);
            srb2Lists[i] = createDropdown(i, "srb2_ch_"+(i+1), boardSettings.values.srb2[i].values(), boardSettings.values.srb2[i]);
            srb1Lists[i] = createDropdown(i, "srb1_ch_"+(i+1), boardSettings.values.srb1[i].values(), boardSettings.values.srb1[i]);
        }

        resizeDropdowns(_channelBarHeight);
    }

    public void updateChanSettingsDropdowns(int chan, boolean isActive, color defaultColor) {
        color c = isActive ? defaultColor : color(50);
        gainLists[chan].setValue(boardSettings.values.gain[chan].ordinal());
        gainLists[chan].setColorBackground(c);
        gainLists[chan].setLock(!isActive);
        inputTypeLists[chan].setValue(boardSettings.values.inputType[chan].ordinal());
        inputTypeLists[chan].setColorBackground(c);
        inputTypeLists[chan].setLock(!isActive);
        biasLists[chan].setValue(boardSettings.values.bias[chan].ordinal());
        biasLists[chan].setColorBackground(c);
        biasLists[chan].setLock(!isActive);
        srb2Lists[chan].setValue(boardSettings.values.srb2[chan].ordinal());
        srb2Lists[chan].setColorBackground(c);
        srb2Lists[chan].setLock(!isActive);
        srb1Lists[chan].setValue(boardSettings.values.srb1[chan].ordinal());
        srb1Lists[chan].setColorBackground(c);
        srb1Lists[chan].setLock(!isActive);
        hasUnappliedChanges[chan] = false;
    }

    private class SLCallbackListener implements CallbackListener {
        private int channel;
    
        SLCallbackListener(int _i)  {
            channel = _i;
        }
        public void controlEvent(CallbackEvent theEvent) {
            
            //Selecting an item from ScrollableList triggers Broadcast
            if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) { 
                int val = (int)(theEvent.getController()).getValue();
                Map bob = ((ScrollableList)theEvent.getController()).getItem(val);
                ADSSettingsEnum myEnum = (ADSSettingsEnum)bob.get("value");
                verbosePrint("HardwareSettings: " + (theEvent.getController()).getName() + " == " + myEnum.getName());

                if (myEnum instanceof Gain) {
                    //verbosePrint("HardwareSettings: previousVal == " + boardSettings.previousValues.gain[channel]);
                    hasUnappliedChanges[channel] = (Gain)myEnum != boardSettings.values.gain[channel];
                    boardSettings.values.gain[channel] = (Gain)myEnum;
                } else if (myEnum instanceof InputType) {
                    hasUnappliedChanges[channel] = (InputType)myEnum != boardSettings.values.inputType[channel];
                    boardSettings.values.inputType[channel] = (InputType)myEnum;
                } else if (myEnum instanceof Bias) {
                    hasUnappliedChanges[channel] = (Bias)myEnum != boardSettings.values.bias[channel];
                    boardSettings.values.bias[channel] = (Bias)myEnum;
                } else if (myEnum instanceof Srb2) {
                    hasUnappliedChanges[channel] = (Srb2)myEnum != boardSettings.values.srb2[channel];
                    boardSettings.values.srb2[channel] = (Srb2)myEnum;
                } else if (myEnum instanceof Srb1) {
                    hasUnappliedChanges[channel] = (Srb1)myEnum != boardSettings.values.srb1[channel];
                    boardSettings.values.srb1[channel] = (Srb1)myEnum;
                }

                hasUnappliedChanges[channel] = !boardSettings.equalsLastValues(channel);
            }
        }
    }
};

void loadHardwareSettings(File selection) {
    if (selection == null) {
        output("Hardware Settings file not selected.");
    } else {
        if (currentBoard instanceof ADS1299SettingsBoard) {
            if (((ADS1299SettingsBoard)currentBoard).getADS1299Settings().loadSettingsValues(selection.getAbsolutePath())) {
                outputSuccess("Hardware Settings Loaded!");
            } else {
                outputError("Failed to load Hardware Settings.");
            }
        }
    }
}

void storeHardwareSettings(File selection) {
    if (selection == null) {
        output("Hardware Settings file not selected.");
    } else {
        if (currentBoard instanceof ADS1299SettingsBoard) {
            if (((ADS1299SettingsBoard)currentBoard).getADS1299Settings().saveToFile(selection.getAbsolutePath())) {
                outputSuccess("Hardware Settings Saved!");
            } else {
                outputError("Failed to save Hardware Settings.");
            }
        }
    }
}