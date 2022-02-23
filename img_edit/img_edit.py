import tkinter as tk

VRAM = []

# Save/open as custom format (JSON -> palette info + image info)
# Export as 2bpp, 4bpp, mode 7 -> warning if two many colors ? strip ?
# Export as png ?
# 2bpp -> 8 palettes of 4 colors, = 32 colors max
# 4bpp -> 8 palettes of 16 colors = 256 colors max
# mode 7 -> 256 colors max

def hex_to_rgb(color_hex):
    color_code = color_hex.lstrip('#')
    return tuple(int(color_code[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb_tuple):
    c = rgb_tuple[0] << 16 | rgb_tuple[1] << 8 | rgb_tuple[2]
    return '#{0:06x}'.format(c)

class ImageEditor(tk.Frame):
    WINDOW_WIDTH = 800
    WINDOW_HEIGHT = 800

    def __init__(self, parent, *args, **kwargs):
        super().__init__()

        self.master.title('Super Famicom Image Editor')

        screen_width = self.winfo_screenwidth()
        screen_height = self.winfo_screenheight()
        center_x = int(screen_width / 2 - self.WINDOW_WIDTH / 2)
        center_y = int(screen_height / 2 - self.WINDOW_HEIGHT / 2)

        self.master.geometry(f'{self.WINDOW_WIDTH}x{self.WINDOW_HEIGHT}+{center_x}+{center_y}')
        self.master.resizable(False, False)

        self.init_widgets()

    def init_widgets(self):
        message = tk.Label(self, text="Hello world")
        message.place(x=10, y=0)

        button = tk.Button(self, text="Display palette", command=self.issoufle)
        button.place(x=10, y=40)

        vram_viewer = VRAMViewer(self)
        vram_viewer.place(x=10, y=100)

        edit_zone = EditZone(self)
        edit_zone.place(x=286, y=100)

        color_slider = ColorSlider(self)
        palette_viewer = PaletteViewer(self, color_slider=color_slider)

        color_slider.palette_viewer = palette_viewer

        self.palettes = palette_viewer.color_list

        palette_viewer.place(x=286, y=376)
        color_slider.place(x=286, y=524)

    def issoufle(self):
        print(self.palettes)


class ColorSlider(tk.Frame):
    def __init__(self, parent, *args, **kwargs):
        super().__init__()

        self.red_slider = tk.Scale(self, from_=0, to=255, orient=tk.HORIZONTAL, command=self.update_color, length=256)
        self.red_slider.pack()

        self.green_slider = tk.Scale(self, from_=0, to=255, orient=tk.HORIZONTAL, command=self.update_color, length=256)
        self.green_slider.pack()

        self.blue_slider = tk.Scale(self, from_=0, to=255, orient=tk.HORIZONTAL, command=self.update_color, length=256)
        self.blue_slider.pack()

        self.color_var = tk.StringVar()
        color = tk.Label(self, textvariable=self.color_var)
        color.pack()

        self.color_preview = tk.Canvas(self, width=20, height=20)
        self.color_preview.pack()

        self.palette_viewer = None

        self.update_color()


    def update_color(self, value = None):
        color_hex = rgb_to_hex((self.red_slider.get(), self.green_slider.get(), self.blue_slider.get()))

        self.color_var.set(color_hex)
        self.color_preview.configure(bg=color_hex)

        if self.palette_viewer == None:
            return

        self.palette_viewer.update_selected_color(color_hex)

    def set_color(self, rgb):
        self.red_slider.set(rgb[0])
        self.green_slider.set(rgb[1])
        self.blue_slider.set(rgb[2])


class PaletteViewer(tk.Frame):
    # TODO canvas
    # 8x16 colors
    # click on color -> make it active in color slider.
    # changing active color in color slider -> change current selected color in current palette
    CELL_SIZE = 16
    PALETTE_WIDTH = 16
    PALETTE_COUNT = 8

    def __init__(self, parent, *args, **kwargs):
        super().__init__()

        self.canvas = tk.Canvas(self, width=self.CELL_SIZE * self.PALETTE_WIDTH,
                                      height=self.CELL_SIZE * self.PALETTE_COUNT,
                                      bg='#6b6b6b', highlightthickness=0, borderwidth=0)
        self.canvas.pack()

        self.init_colors()

        x = 0
        y = 0
        self.select_box = self.canvas.create_rectangle(x, y, x+self.CELL_SIZE, y+self.CELL_SIZE, outline='#fff', state='hidden')

        self.canvas.bind('<Button-1>', self.select_color)

        self.color_slider = kwargs['color_slider']

        self.selected_color = None

    def init_colors(self):
        self.color_list = [(128, 128, 128) for i in range(16 * 8)]

        i = 0
        for color in self.color_list:
            x = i % 16
            y = i // 16

            color_hex = rgb_to_hex(self.color_list[i])

            self.canvas.create_rectangle(x * 16, y * 16, (x * 16)+self.CELL_SIZE, (y * 16)+self.CELL_SIZE, fill=color_hex, outline=color_hex)

            i += 1

    def select_color(self, e):
        x = e.x // self.CELL_SIZE * 16
        y = e.y // self.CELL_SIZE * 16

        item = self.canvas.find_closest(e.x, e.y)
        if item[0] == self.select_box: return

        self.selected_color = item[0]

        selected_color_code = self.canvas.itemcget(self.selected_color, 'fill')
        rgb = hex_to_rgb(selected_color_code)


        self.color_slider.set_color(rgb)

        self.canvas.coords(self.select_box, x, y, x + self.CELL_SIZE, y + self.CELL_SIZE)
        self.canvas.itemconfig(self.select_box, state='normal')


    def update_selected_color(self, color_hex):
        if self.selected_color == None:
            return

        self.canvas.itemconfig(self.selected_color, fill=color_hex, outline=color_hex)

        new_color = hex_to_rgb(color_hex)

        coords = self.canvas.coords(self.selected_color)

        x = coords[0] // 16
        y = coords[1] // 16
        i = x + y * self.PALETTE_WIDTH

        self.color_list[int(i)] = new_color

class VRAMViewer(tk.Frame):
    # VRAM in 2bpp   -> 128px x 2048px
    # VRAM in 4bpp   -> 128px x 1024px
    # VRAM in mode 7 -> 128px x 256px

    def __init__(self, parent, *args, **kwargs):
        super().__init__()

        self.vram_viewer = tk.Canvas(self, width=256, height=256, bg='#000')
        self.vram_viewer.bind('<Button-1>', self.ronrure)

        self.vram_viewer.pack()

        x = 16
        y = 16

        self.vram_viewer.create_rectangle(x, y, x+64, y+64, outline='#fff')

    def ronrure(self, x):
        print(x)

class EditZone(tk.Frame):
    # TODO
    # clicking on canvas : draw one pixel of selected index in palette viewer
    # EditZone StartX -> top left corner of selection in VRAM viewer
    # EditZone StartY -> top left corner of selection in VRAM viewer
    # edit VRAM according to current BPP settings (2, 4 or mode 7)

    def __init__(self, parent, *args, **kwargs):
        super().__init__()

        self.edit_zone = tk.Canvas(self, width=256, height=256, bg='#000')
        self.edit_zone.pack()


if __name__ == "__main__":
    root = tk.Tk()
    ImageEditor(root).pack(fill="both", expand=True)
    root.mainloop()
