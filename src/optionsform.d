// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.Window: Window;

final class OptionsForm: Window {
    import common: APPNAME;
    import config: config, MIN_BOARD_SIZE, MAX_BOARD_SIZE, MIN_COLORS,
           MIN_DELAY, MAX_DELAY;
    import gdk.Event: Event;
    import gtk.Button: Button;
    import gtk.Label: Label;
    import gtk.SpinButton: SpinButton;
    import gtk.ToolButton: ToolButton;
    import gtk.Widget: Widget;

    private {
        alias OnChangeBoardFn = void delegate(ToolButton);

        OnChangeBoardFn onChangeBoard;
        Label columnsLabel;
        SpinButton columnsSpinButton;
        Label rowsLabel;
        SpinButton rowsSpinButton;
        Label maxColorsLabel;
        SpinButton maxColorsSpinButton;
        Label delayMsLabel;
        SpinButton delayMsSpinButton;
        Button okButton;
        Button cancelButton;
    }

    this(OnChangeBoardFn onChangeBoard, Window parent) {
        this.onChangeBoard = onChangeBoard;
        super("Options — " ~ APPNAME);
        setTransientFor(parent);
        setModal(true);
        makeWidgets;
        makeLayout;
        addOnKeyPress(&onKeyPress);
        showAll;
    }

    private void makeWidgets() {
        import color: COLORS;
        import gtkc.gtktypes: StockID;

        columnsLabel = new Label("Co_lumns");
        columnsSpinButton = new SpinButton(MIN_BOARD_SIZE, MAX_BOARD_SIZE,
                                           1);
        columnsSpinButton.setValue(config.columns);
        columnsLabel.setMnemonicWidget(columnsSpinButton);
        rowsLabel = new Label("_Rows");
        rowsSpinButton = new SpinButton(MIN_BOARD_SIZE, MAX_BOARD_SIZE, 1);
        rowsSpinButton.setValue(config.rows);
        rowsLabel.setMnemonicWidget(rowsSpinButton);
        maxColorsLabel = new Label("_Max. Colors");
        maxColorsSpinButton = new SpinButton(MIN_COLORS, COLORS.length, 1);
        maxColorsSpinButton.setValue(config.maxColors);
        maxColorsLabel.setMnemonicWidget(maxColorsSpinButton);
        delayMsLabel = new Label("_Delay (ms)");
        delayMsSpinButton = new SpinButton(MIN_DELAY, MAX_DELAY, 10);
        delayMsSpinButton.setValue(config.delayMs);
        delayMsLabel.setMnemonicWidget(delayMsSpinButton);
        okButton = new Button(StockID.OK);
        okButton.addOnClicked(&onOk);
        cancelButton = new Button(StockID.CANCEL);
        cancelButton.addOnClicked(&onCancel);
    }

    private void makeLayout() {
        import gtk.Grid: Grid;

        auto grid = new Grid;
        grid.attach(columnsLabel, 0, 0, 1, 1);
        grid.attach(columnsSpinButton, 1, 0, 1, 1);
        grid.attach(rowsLabel, 0, 1, 1, 1);
        grid.attach(rowsSpinButton, 1, 1, 1, 1);
        grid.attach(maxColorsLabel, 0, 2, 1, 1);
        grid.attach(maxColorsSpinButton, 1, 2, 1, 1);
        grid.attach(delayMsLabel, 0, 3, 1, 1);
        grid.attach(delayMsSpinButton, 1, 3, 1, 1);
        grid.attach(okButton, 0, 4, 1, 1);
        grid.attach(cancelButton, 1, 4, 1, 1);
        add(grid);
    }

    private void onOk(Button) {
        int columns = columnsSpinButton.getValueAsInt;
        int rows = rowsSpinButton.getValueAsInt;
        int maxColors = maxColorsSpinButton.getValueAsInt;
        int delayMs = delayMsSpinButton.getValueAsInt;
        if (columns != config.columns || rows != config.rows ||
                maxColors != config.maxColors ||
                delayMs != config.delayMs) {
            config.columns = columns;
            config.rows = rows;
            config.maxColors = maxColors;
            config.delayMs = delayMs;
            config.save;
            onChangeBoard(null);
        }
        close;
    }

    private void onCancel(Button) {
        close;
    }

    private bool onKeyPress(Event event, Widget) {
        import gdk.Keymap: Keymap;

        uint kv;
        event.getKeyval(kv);
        if (Keymap.keyvalName(kv) == "Escape") {
            destroy;
            return true;
        }
        return false;
    }
}
