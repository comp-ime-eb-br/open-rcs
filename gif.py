import tkinter as tk
from PIL import Image, ImageTk
from itertools import count, cycle

class ImageLabel(tk.Label):
    """
    A Label that displays images, and plays them if they are gifs
    :im: A PIL Image instance or a string filename
    """
    def load(self, im):
        if isinstance(im, str):
            im = Image.open(im)
        frames = []

        try:
            for i in count(1):
                frames.append(ImageTk.PhotoImage(im.copy().resize((100, 100))))
                im.seek(i)
        except EOFError:
            pass
        self.frames = cycle(frames)

        try:
            self.delay = im.info['duration']
        except:
            self.delay = 100

        if len(frames) == 1:
            self.config(image=next(self.frames),width=100,height=100,bg='#e8e4e4')
        else:
            self.next_frame()

    def unload(self):
        self.config(image=None,width=100,height=100,bg='#e8e4e4')
        self.frames = None

    def next_frame(self):
        if self.frames:
            self.config(image=next(self.frames),width=100,height=100,bg='#e8e4e4')
            self.after(self.delay, self.next_frame)

