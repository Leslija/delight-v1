$(document).ready(function () {
    $("body").on("keyup", function (key) {
        if (key.which === 113 || key.which == 27 || key.which == 90) {
            $.post("https://qb-ambulancejob/CloseActives");
        }
    });
});

window.addEventListener("message", function (event) {
    let action = event.data.action;
    let data = event.data.data;

    if (action == 'open') {
        $(".app").fadeIn(500);
    } else if (action == 'drag') {
        $(".app").fadeIn(500);
        dragElement(document.getElementById("app"));
    } else if (action == 'close') {
        $(".app").fadeOut(500);
    } else if (action == 'refresh') {
        $(".officers").html(data);
    }
})

function dragElement(elmnt) {
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
  if (document.getElementById(elmnt.id + "header")) {
    // if present, the header is where you move the DIV from:
    document.getElementById(elmnt.id + "header").onmousedown = dragMouseDown;
  } else {
    // otherwise, move the DIV from anywhere inside the DIV:
    elmnt.onmousedown = dragMouseDown;
  }

  function dragMouseDown(e) {
    e = e || window.event;
    e.preventDefault();
    // get the mouse cursor position at startup:
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    // call a function whenever the cursor moves:
    document.onmousemove = elementDrag;
  }

  function elementDrag(e) {
    e = e || window.event;
    e.preventDefault();
    // calculate the new cursor position:
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    // set the element's new position:
    elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
    elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
  }

  function closeDragElement() {
    // stop moving when mouse button is released:
    document.onmouseup = null;
    document.onmousemove = null;
  }
}