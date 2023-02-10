use pam::Authenticator;

use eframe::egui;

fn main() {
    let mut native_options = eframe::NativeOptions::default();
    native_options.initial_window_size = Some(egui::vec2(200.0, 120.0));
    eframe::run_native(
        "SDC",
        native_options,
        Box::new(|cc| Box::new(DevConsole::new(cc))),
    );
}

#[derive(Default)]
struct DevConsole {
    username: String,
    password: String,
}

impl DevConsole {
    fn new(_cc: &eframe::CreationContext<'_>) -> Self {
        // Customize egui here with cc.egui_ctx.set_fonts and cc.egui_ctx.set_visuals.
        // Restore app state using cc.storage (requires the "persistence" feature).
        // Use the cc.gl (a glow::Context) to create graphics shaders and buffers that you can use
        // for e.g. egui::PaintCallback.
        Self::default()
    }
}

impl eframe::App for DevConsole {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.label("Enter Username");
            ui.text_edit_singleline(&mut self.username);
            ui.label("Enter Password");
            ui.text_edit_singleline(&mut self.password);
            if ui.button("Login").clicked() {
                switch_user(&self.username, &self.password);
            }
        });
    }
}

fn switch_user(username: &str, password: &str) {
    let mut authenticator = Authenticator::with_password("xr-login").unwrap();
    authenticator
        .get_handler()
        .set_credentials(username, password);
    authenticator
        .authenticate()
        .expect("authentication failed!");
    authenticator.open_session().unwrap();
}
