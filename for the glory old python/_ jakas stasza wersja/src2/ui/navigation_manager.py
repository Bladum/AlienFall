# ui/navigation_manager.py
class NavigationManager:
    def __init__(self):
        self.main_window = None

    def set_main_window(self, main_window):
        self.main_window = main_window

    def switch_to_starter(self):
        if self.main_window:
            self.main_window.switch_to_starter_widget()

    def switch_to_options(self):
        if self.main_window:
            self.main_window.switch_to_options_widget()

    def switch_to_pick_scenario(self, selected_mod=None):
        if self.main_window:
            self.main_window.switch_to_pick_scenario_widget(selected_mod)

    def switch_to_editor(self):
        if self.main_window:
            self.main_window.switch_to_editor_widget()

    def switch_to_wiki(self):
        if self.main_window:
            self.main_window.switch_to_wiki_widget()

    def switch_to_battle(self):
        if self.main_window:
            self.main_window.switch_to_battle_widget()

    def switch_to_game(self, scenario=None):
        if self.main_window:
            self.main_window.switch_to_game_widget(scenario)

    def exit_app(self):
        if self.main_window:
            self.main_window.exit_application()


# Create a singleton instance
navigation = NavigationManager()