const width = 100;
const height = 100;
const radius = Math.min(width, height) / 2;

const svg1 = d3.select("#elementsChart")
    .append("svg")
        .attr("width", width)
        .attr("height", height)
    .append("g")
        .attr("transform", `translate(${width / 2}, ${height / 2})`);
        
const svg2 = d3.select("#attClassesChart")
    .append("svg")
        .attr("width", width)
        .attr("height", height)
    .append("g")
        .attr("transform", `translate(${width / 2}, ${height / 2})`);
        
const svg3 = d3.select("#modelClassesChart")
    .append("svg")
        .attr("width", width)
        .attr("height", height)
    .append("g")
        .attr("transform", `translate(${width / 2}, ${height / 2})`);
        
const svg4 = d3.select("#macroPeChart")
    .append("svg")
        .attr("width", width)
        .attr("height", height)
    .append("g")
        .attr("transform", `translate(${width / 2}, ${height / 2})`);
        
const svg5 = d3.select("#macroDtChart")
    .append("svg")
        .attr("width", width)
        .attr("height", height)
    .append("g")
        .attr("transform", `translate(${width / 2}, ${height / 2})`);

const className = d3.scaleOrdinal(["added","changed","removed",
     "unchanged"]);

const pie = d3.pie()
    .value(d => d.count)
    .sort(null);

const arc = d3.arc()
    .innerRadius(0)
    .outerRadius(radius);

function handleClick(d,i) {
    document.querySelector(d.data.ref).scrollIntoView();
}

function getCharts() {
    // Join new data
    const path1 = svg1.selectAll("path")
        .data(pie(elements));
    
    // Enter new arcs
    path1.enter().append("path")
        .attr("d", arc)
        .attr("stroke", "white")
        .attr("stroke-width", "1px")
        .attr('class',(d, i) => className(i))
        .on('click',handleClick)
    .append("title")
        .text(d => `${d.data.count} ${d.data.type} elements`)
        
        // Join new data
    const path2 = svg2.selectAll("path")
        .data(pie(attClasses));
    
    // Enter new arcs
    path2.enter().append("path")
        .attr("d", arc)
        .attr("stroke", "white")
        .attr("stroke-width", "1px")
        .attr('class',(d, i) => className(i))
        .on('click',handleClick)
    .append("title")
        .text(d => `${d.data.count} ${d.data.type} attribute classes`)
        
        // Join new data
    const path3 = svg3.selectAll("path")
        .data(pie(modelClasses));
    
    // Enter new arcs
    path3.enter().append("path")
        .attr("d", arc)
        .attr("stroke", "white")
        .attr("stroke-width", "1px")
        .attr('class',(d, i) => className(i))
        .on('click',handleClick)
    .append("title")
        .text(d => `${d.data.count} ${d.data.type} model classes`)
        
        // Join new data
    const path4 = svg4.selectAll("path")
        .data(pie(macroPe));
    
    // Enter new arcs
    path4.enter().append("path")
        .attr("d", arc)
        .attr("stroke", "white")
        .attr("stroke-width", "1px")
        .attr('class',(d, i) => className(i))
        .on('click',handleClick)
    .append("title")
        .text(d => `${d.data.count} ${d.data.type} macroSpecs (parameter entities)`)
        
        // Join new data
    const path5 = svg5.selectAll("path")
        .data(pie(macroDt));
    
    // Enter new arcs
    path5.enter().append("path")
        .attr("d", arc)
        .attr("stroke", "white")
        .attr("stroke-width", "1px")
        .attr('class',(d, i) => className(i))
        .on('click',handleClick)
    .append("title")
        .text(d => `${d.data.count} ${d.data.type} macroSpecs (data types)`)
}

getCharts();
