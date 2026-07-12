from libqtile.widget import WindowName


CLASS_DISPLAY_MAP = {
    "org.wezfurlong.wezterm": "wezterm",
}


class CleanWindowName(WindowName):
    def hook_response(self, *args):
        super().hook_response(*args)
        for ugly, clean in CLASS_DISPLAY_MAP.items():
            if ugly in self.text:
                self.text = self.text.replace(ugly, clean)
                if self.bar:
                    self.bar.draw()
                break
