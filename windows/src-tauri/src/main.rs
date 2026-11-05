// Bholeynath runs without a console window: Narayan is the whole UI.
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    bholeynath_lib::run()
}
