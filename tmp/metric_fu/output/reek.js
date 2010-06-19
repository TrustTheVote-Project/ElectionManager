              var g = new Bluff.Line('graph', "1000x600");
      g.theme_37signals();
      g.tooltips = true;
      g.title_font_size = "24px"
      g.legend_font_size = "12px"
      g.marker_font_size = "10px"

        g.title = 'Reek: code smells';
        g.data('ControlCouple', [11])
g.data('DataClump', [2])
g.data('Duplication', [361])
g.data('IrresponsibleModule', [38])
g.data('LargeClass', [1])
g.data('LongMethod', [96])
g.data('LongParameterList', [12])
g.data('LowCohesion', [66])
g.data('NestedIterators', [57])
g.data('SimulatedPolymorphism', [10])
g.data('UncommunicativeName', [134])

        g.labels = {"0":"6/19"};
        g.draw();
