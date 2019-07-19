(function() {
    const diameter = 600; // max size of the bubbles
    const color    = d3.scaleOrdinal(d3.schemeCategory20b); // color category
    
    const pack = d3
        .pack()
        .size([diameter, diameter])
        .padding(1.5);
    const svg = d3
        .select("svg#pga-licenses")
        .attr("width", diameter)
        .attr("height", diameter)
        .attr("class", "bubble")
        .style("display", "table")
        .style("margin", "0 auto");
    
    d3.csv("/post/gld/pga-licenses.csv",
    d => { d.value = +d["Frequency"]; d.text = d["License"]; return d; },
    (error, data) => {
        if (error) throw error;
        const max = d3.max(d3.values(data)).value;
        const root = d3.hierarchy({children: data})
            .sum(d => d.value)
            .sort((a, b) => (b.value - a.value));
        const bubbles = svg.selectAll(".node")
            .data(pack(root).leaves())
            .enter()
            .append("g")
            .attr("class", "node");
        bubbles.append("circle")
            .attr("r", d => d.r)
            .attr("cx", d => d.x)
            .attr("cy", d => d.y)
            .style("fill", d => (d.data.text == "?"? "gray" : color(d.value)));
        bubbles.append("text")
            .attr("x", d => d.x)
            .attr("y", d => d.y)
            .attr("text-anchor", "middle")
            .attr("alignment-baseline", "middle")
            .text(d => d.data.text)
            .style("font-family", "Helvetica Neue, Helvetica, Arial, sans-serif")
            .style("font-size", d => ((Math.pow(d.value / max, 0.33) * 32) | 0) + "px")
            .style("fill", d => d.value > 800? "white" : "none");
    })
})();