// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
// import {Socket} from "phoenix"
import socket from "./socket";
//
// import "phoenix_html";

//Draw bare grid
function drawPlayField() {
  for (var row = 0; row < 5; row++) {
    $("#playfield").append('<tr class="' + row + '"></tr>');
    for (var col = 0; col < 5; col++) {
      $("." + row).append('<td id="' + col + '"></td>');
    }
  }
}

$(document).ready(function () {
  drawPlayField();
});

function clearGrid() {
  for (var row = 0; row < 5; row++) {
    for (var col = 0; col < 5; col++) {
      var $coor = $("." + row).find("#" + col);
      $coor.removeAttr("bgcolor");
    }
  }
}
export function renderGrid(grid) {
  clearGrid();

  const gridValues = Object.values(grid);
  gridValues.forEach(function (creatures, index) {
    var $coor = $("." + parseInt(index / 5)).find("#" + (index % 5));

    if (creatures.includes("C")) {
      $coor.attr("bgcolor", "green");
    } else if (creatures.includes("R")) {
      $coor.attr("bgcolor", "blue");
    } else if (creatures.includes("F")) {
      $coor.attr("bgcolor", "red");
    }
  });

  //   grid.forEach(function (cell) {
  //     console.log(cell)

  //     var row = parseInt(index / 5);
  //     var col = index % 5;
  //     var $coor = $("." + row).find("#" + col);

  //     if (gridValues[index].includes("C")) {
  //       $coor.attr("bgcolor", "green");
  //     } else if (gridValues[index].includes("R")) {
  //       $coor.attr("bgcolor", "blue");
  //     } else if (gridValues[index].includes("F")) {
  //       $coor.attr("bgcolor", "red");
  //     } else {
  //       $coor.attr("bgcolor", "black");
  //     }
  //   });

  // console.log(cells)
}
