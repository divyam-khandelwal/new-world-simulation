

var cells = document.querySelectorAll('span')

export function renderGrid(grid) {

    // cells.forEach((cell, index) => {
    //     console.log(cell, index);
    //     console.grid(grid[index])
    //   });

    const gridValues = Object.values(grid);
    
    cells.forEach(
        function(cell, index) {
            console.log(gridValues[index])

            if(gridValues[index].includes('C')){
                $(cell).attr('class', 'carrot');
            }
            else if(gridValues[index].includes('R')){
                $(cell).attr('class', 'rabbit');
            }
            else if(gridValues[index].includes('F')){
                $(cell).attr('class', 'fox');
            } else {
                $(cell).attr('class', 'plot');
            }
        }
      );
      
    // console.log(cells)
    
}