              var g = new Bluff.Line('graph', "1000x600");
      g.theme_37signals();
      g.tooltips = true;
      g.title_font_size = "24px"
      g.legend_font_size = "12px"
      g.marker_font_size = "10px"

        g.title = 'Flog: code complexity';
        g.data('average', [15.1]);
        g.data('top 5% average', [93.9136363636364])
        g.labels = {"0":"6/19"};
        g.draw();
