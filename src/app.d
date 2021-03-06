// Copyright © 2020 Mark Summerfield. All rights reserved.
module qtrac.gravitate.app;

int main(string[] args) {
    import gio.Application: GioApplication = Application;
    import gtk.Application: Application;
    import gtk.ApplicationWindow: GApplicationFlags;

    auto application = new Application("eu.qtrac.gravitate",
                                       GApplicationFlags.FLAGS_NONE);
    application.addOnActivate(delegate void(GioApplication) {
        import qtrac.gravitate.config: config;
        import qtrac.gravitate.gamewindow: GameWindow;

        config.load(application.getApplicationId);
        new GameWindow(application);
    });
    return application.run(args);
}
