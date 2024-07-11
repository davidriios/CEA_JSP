let iconsList = ["glyphicon-off",
    "glyphicon-heart",
    "glyphicon-lock",
    "glyphicon-leaf",
    "glyphicon glyphicon-wrench",
    "glyphicon glyphicon-gift",
    "glyphicon glyphicon-fire",
    "glyphicon glyphicon-comment",
    "glyphicon glyphicon-folder-close",
    "glyphicon glyphicon-hdd",
    "glyphicon glyphicon-bell",
    "glyphicon glyphicon-tasks",
    "glyphicon glyphicon-filter",
    "glyphicon glyphicon-paperclip",
    "glyphicon glyphicon-dashboard",
    "glyphicon glyphicon-link",
    "glyphicon glyphicon-pushpin",
    "glyphicon glyphicon-send"];

let iconsPerSection = [
    { id: 16, displayLabel: "Administraci\u00F3n", icon: "glyphicon glyphicon-cog" },
    { id: 16, displayLabel: "Administracion", icon: "glyphicon glyphicon-cog" },
    { id: 29, displayLabel: "Admisi\u00F3n", icon: "glyphicon glyphicon-copy" },
    { id: 29, displayLabel: "Admision", icon: "glyphicon glyphicon-copy" },
    { id: 538, displayLabel: "Expediente", icon: "glyphicon glyphicon-folder-open" },
    { id: 132, displayLabel: "Facturaci\u00F3n", icon: "glyphicon glyphicon-list" },
    { id: 132, displayLabel: "Facturacion", icon: "glyphicon glyphicon-list" },
    { id: 195, displayLabel: "RRHH", icon: "glyphicon glyphicon-user" },
    { id: 200, displayLabel: "Planilla", icon: "glyphicon glyphicon-list-alt" },
    { id: 359, displayLabel: "CXC", icon: "glyphicon glyphicon-import" },
    { id: 398, displayLabel: "Caja", icon: "glyphicon glyphicon-usd" },
    { id: 437, displayLabel: "Convenios", icon: "glyphicon glyphicon-ok-circle" },
    { id: 9, displayLabel: "Compras", icon: "glyphicon glyphicon-shopping-cart" },
    { id: 1, displayLabel: "Inventario", icon: "glyphicon glyphicon-equalizer" },
    { id: 657, displayLabel: "Citas", icon: "glyphicon glyphicon-calendar" },
    { id: 833, displayLabel: "CXP", icon: "glyphicon glyphicon-export" },
    { id: 860, displayLabel: "Farmacia", icon: "glyphicon glyphicon-modal-window" },
    { id: 899, displayLabel: "Bancos", icon: "glyphicon glyphicon-globe" },
    { id: 1046, displayLabel: "Presupuesto", icon: "glyphicon glyphicon-stats" },
    { id: 1113, displayLabel: "Mayor General", icon: "glyphicon glyphicon-king" },
    { id: 707, displayLabel: "BI Reports", icon: "glyphicon glyphicon-signal" },
    { id: 1148, displayLabel: "POS", icon: "glyphicon glyphicon-print" },
    { id: 1174, displayLabel: "Plan M\u00E9dico", icon: "glyphicon glyphicon-bed" },
    { id: 1198, displayLabel: "Activos Fijos", icon: "glyphicon glyphicon-book" },
    { id: 1416, displayLabel: "Dashboard", icon: "glyphicon glyphicon-dashboard" },
    { id: 1488, displayLabel: "Correo", icon: "glyphicon glyphicon-envelope" }
];

var Nav2;

const theSearchInput = "" +
    "  <li > " +
    " <form class=\"form-inline text-left\" onSubmit=\"return false;\" onblur=\"emptyTopMenuSearch()\" >" +
    " <span class=\"glyphicon glyphicon-search \"> </span>" +
    "<input " +
    "id=\"topMenuSearchInputField\" " +
    "class=\"top-menu-search-input form-control mr-sm-2\" " +
    "type=\"search\" " +
    "autocomplete=\"off\" " +
    "style=\"width: 80%; margin-left: 7%;\" " +
    "placeholder=\"Buscar\" " +
    "onKeyUp=\"preSearchMatchingMenuOption(event, this.value)\" " +
    "onFocus=\"searchMatchingMenuOption(this.value)\" " +
    "" +
    "aria-label=\"Buscar\" > " +
    "<div  " +
    "id=\"topMenuSearchConfig\" " +
    "class=\"top-menu-config \" " +
    "style=\"\" " +
    ">" +
    " <label for=\"colorWell\" >" +
    "<span class=\"glyphicon glyphicon-cog top-menu-option-wrench-img \" style=\"display: none\"></span>" +
    "<input type=\"color\" onchange=\"changeColorEvent(event)\" id=\"colorWell\" style=\"display: none\">" +
    "</label>" +
    " </div>" +
    "<div tabindex=\"1\" " +
    "id=\"topMenuSearchResultsContainer\" " +
    "class=\"top-menu-search-results-container\" " +
    "style=\"\" " +
    "></div>" +
    "</form>  " +
    " </li>";


function changeColorEvent(event) {

    changeColor(event.target.value);

    colorMenu = event.target.value;

}
function changeColor(color) {



    var elements = document.getElementsByClassName('glyphicon');
    for (var i = 0; i < elements.length; i++) {
        elements[i].style.color = color;
    }
    var elements2 = document.getElementsByClassName('top-menu-option');
    for (var j = 0; j < elements2.length; j++) {
        elements2[j].style.setProperty('--td-backgroundMenu-color', color);
    }
    var elements3 = document.getElementsByClassName('top-menu-text');
    for (var k = 0; k < elements3.length; k++) {
        elements3[k].style.setProperty('--td-backgroundMenu-color', color);
    }

    var elements4 = document.getElementsByClassName('hc-nav-trigger');
    for (var l = 0; l < elements4.length; l++) {

        elements4[l].getElementsByTagName('span')[0].style.display = "block";//  .style.setProperty('--td-backgroundMenu-color', color);;
    }
}


function delegateToNav(index) {
    toggleMenu();
    Nav2.toggle();
    Nav2.open(1, index);
}
const myMap = new Map();
const urlMap = new Map();

function loadNav() {
    sortMenuBasedOnCustomizedPositions(menuItems);
    let leftListOfMainMenus =    "  <nav id=\"navID\"   >"   ;
    let parentIndex = 0;
    menuItems.forEach((item, index) => {
        if (index === 0)
            myMap.set(0, myMap.get(0) === undefined ? 0 : myMap.get(0) + 1);

        if (item.parentId == 0)
            leftListOfMainMenus += "<span " +
                "class=\" " +
                getIconByMenuId(item.id) +
                " top-menu-left-container-img \" " +
                "></span>";
        leftListOfMainMenus += "<ul role=menu class=\"second-nav\"> ";

        if (index === 0)
            leftListOfMainMenus += theSearchInput;
        leftListOfMainMenus += nodeList(item, 0, index);
        leftListOfMainMenus += "</ul> ";

    });

    leftListOfMainMenus += "</nav>";
    document.getElementById("container").innerHTML = "" + leftListOfMainMenus;


    var $nav = $('#navID').hcOffcanvasNav({
        width: 450,
        levelTitles: true,
        closeOnClick: true,
        levelOpen: 'overlap',
        closeOpenLevels: true,
        closeActiveLevel: true,
        bodyInsert: 'prepend',
        labelBack: 'Atr\u00E1s',
        labelClose: 'Cerrar',
        disableAt: false,
        ariaLabels: {
          open:     'Open Menu',
          close:    'Close Menu',
          submenu:  'Submenu'
        }
    });

    Nav2 = $nav.data('hcOffcanvasNav');

    changeColor(colorMenu);


    var titlesToUpdate = document.getElementsByClassName('level-title');


    for (var i = 0; i < titlesToUpdate.length; i += 1) {

        var span = document.createElement('span');
        span.innerHTML = "<p>" + titlesToUpdate[i].firstChild.data + "</p>";
        span.className = getIconByMenuName(titlesToUpdate[i].firstChild.data) + " top-menu-left-container-img-nav ";
        titlesToUpdate[i].firstChild.parentNode.appendChild(span);

        titlesToUpdate[i].firstChild.data = "";

    }

    Nav2.on('close', function () {
        emptyTopMenuSearch();
    });

}



function mainLevel(item, parentIndex, index) {

    let list = "" + "<li id= listInner"+ parentIndex +""+parentIndex +" > <a class=\"top-menu-text\"";
    if (item.path) {

        urlMap.set(item.id, [parentIndex, index]);
        list += "href=\"javascript:beforeGoMenuUrl(" + item.id + ", '" + item.path + "', true, true,false)\" ";
    }

    else
        list += "href=\"#\" ";

    list += "id=\"topMenuLeftOptionItem" + index + "\" " +
        ">";
    if (item.parentId == 0){
     list += "<span style=\"display:inline\" " +
                "class=\" " +
                getIconByMenuId(item.id) +
                " top-menu-left-container-img \" " +
                "></span>";
    }else if (item.path) {

     list += "<span " +
     "onclick=\"menuURLinNewTab(event, " +
                                item.id + ", " +
                                "'" + item.path + "')\" "+
                    "class=\"glyphicon glyphicon-new-window " +
                    " top-menu-left-new-window \" " +
                    "></span>";
    }

    list += item.displayLabel +
        "</a>"
    "</li> ";
    return list;
}

function listLevel(item, index) {


    let list = "" + "<li> <a " +
        "href=\"#\" " +
        "id=\"topMenuLeftOptionItem" + index + "\" " +
        ">" +
        item.displayLabel +
        "</a>"
    "</li> ";
    return list;

}
function nodeList(item, parentIndex, index) {
    let list = "";

    list += mainLevel(item, parentIndex, index);
     urlMap.set(item.id, [parentIndex, index]);

    //myMap.set(parentIndex,myMap.get[parentIndex]?0:myMap.get[parentIndex]+1);
    if (item.subMenu && item.subMenu.length > 0) {
        myMap.set(parentIndex + 1, myMap.get(parentIndex + 1) === undefined ? 0 : myMap.get(parentIndex + 1) + 1);
        item.subMenu.forEach((item2, index2) => {
            list += "<ul>";
            list += nodeList(item2, parentIndex + 1, myMap.get(parentIndex + 1));
            list += "</ul>";

        });
    }

    return list;
}


function padZero(str, len) {
    len = len || 2;
    var zeros = new Array(len).join('0');
    return (zeros + str).slice(-len);
}

function getIconByMenuId(menuId) {

    let iconFound = iconsPerSection.find(item => item.id == menuId);
    return (iconFound)
        ? iconFound.icon
        : iconsList[menuId % 18];

}
function getIconByMenuName(menuName) {

    let iconFound = iconsPerSection.find(item => item.displayLabel === menuName);
    return (iconFound)
        ? iconFound.icon
        : "";

}

function initialFunctionInvokedAfterLoadingMain() {

 if (theIdForPostInNewWindow){
var num=theIdForPostInNewWindow.toString();

       Nav2.open(urlMap.get(num)[0], urlMap.get(num)[1]);
      }
        Nav2.close();

    if (theIdForPostInNewWindow && thePathForPostInNewWindow) {
        setTimeout(function () {

          beforeGoMenuUrl(theIdForPostInNewWindow, thePathForPostInNewWindow, true, true);

        }, 123);
    }
}

function toggleMenu() {

    Nav2.open();

}

function sortMenuBasedOnCustomizedPositions(nodeToSort) {

    nodeToSort.sort((a, b) => a.displayOrder - b.displayOrder);

    nodeToSort.sort((a, b) => (a.path && !b.path) ? -1 : 0);

    nodeToSort.forEach(item => sortMenuBasedOnCustomizedPositions(item.subMenu));

}

function preLoadMenu(theEvent) {
    if (theEvent.keyCode === 13)
        loadMenu();
}

function loadMenu() {

}

function preDisplaySubOptions(theEvent, theIndex) {

    switch (theEvent.keyCode) {
        case 13://enter
            displaySubOptions(theIndex);
            break;
        case 37://left
            theEvent.preventDefault();
            if (document.getElementById("topMenuInitialIcons" + (theIndex - 1)))
                document.getElementById("topMenuInitialIcons" + (theIndex - 1)).focus();
            break;
        case 38://up
            theEvent.preventDefault();
            if (document.getElementById("topMenuInitialIcons" + (theIndex - 6)))
                document.getElementById("topMenuInitialIcons" + (theIndex - 6)).focus();
            else if (document.getElementById("topMenuSearchInputField"))
                document.getElementById("topMenuSearchInputField").focus();
            break;
        case 39://right
            theEvent.preventDefault();
            if (document.getElementById("topMenuInitialIcons" + (theIndex + 1)))
                document.getElementById("topMenuInitialIcons" + (theIndex + 1)).focus();
            break;
        case 40://down
            theEvent.preventDefault();
            if (document.getElementById("topMenuInitialIcons" + (theIndex + 6)))
                document.getElementById("topMenuInitialIcons" + (theIndex + 6)).focus();
            break;
    }

}

function keyDownOnTopMenuLeftOptionItem(theEvent, theCurrentIndex) {
    /*
        switch (theEvent.keyCode) {
            case 37://left
                theEvent.preventDefault();
                break;
            case 38://up
                theEvent.preventDefault();
                if ( theCurrentIndex == 0 && document.getElementById("topMenuSearchInputField") )
                    document.getElementById("topMenuSearchInputField").focus();
                else if ( document.getElementById("topMenuLeftOptionItem" + ( theCurrentIndex - 1 )) )
                    document.getElementById("topMenuLeftOptionItem" + ( theCurrentIndex - 1 )).focus();
                break;
            case 39://right
                theEvent.preventDefault();
                let firstRightLinkToPageTag = document.querySelector('[id^="linkToPageTag"], h3[id^="linkToPagesContainer"][tabindex]');
                if ( firstRightLinkToPageTag && ( firstRightLinkToPageTag.style.display === "block"
                                                  || firstRightLinkToPageTag.style.display == "" ) )
                    firstRightLinkToPageTag.focus();
                else {
                    let firstRightLinkToPagesContainer = document.querySelector('h3[id^="linkToPagesContainer"][tabindex]');
                    if ( firstRightLinkToPagesContainer )
                        firstRightLinkToPagesContainer.focus();
                }
                break;
            case 40://down
                theEvent.preventDefault();
                if ( document.getElementById("topMenuLeftOptionItem" + ( theCurrentIndex + 1 )) )
                    document.getElementById("topMenuLeftOptionItem" + ( theCurrentIndex + 1 )).focus();
                break;
        }
    */
}

function displaySubOptions(index) {

    /*   let initiallySelectedIndex = index;
       currentLeftItemSelected = initiallySelectedIndex;

       let leftListOfMainMenus = "<div class=\"list-group\">";

       menuItems.forEach( (item, index) => leftListOfMainMenus += "" +
           "<a " +
               "href=\"javascript:rightDisplaySubOptions(" + index + ")\" " +
               "onKeyDown=\"keyDownOnTopMenuLeftOptionItem(event, " + index + ")\" " +
               "id=\"topMenuLeftOptionItem" + index + "\" " +
               "class=\"list-group-item " +
                       "top-menu-left-container-item" + ( ( initiallySelectedIndex == index )
                                                          ? "-selected "
                                                          : " " ) +
                       "top-menu-remove-focus-outline " +
               "\" " +
           ">" +
               "<span " +
                   "class=\"glyphicon " +
                            getIconByMenuId(item.id) +
                            " top-menu-left-container-img" + ((initiallySelectedIndex==index)?"-selected":"") + "\" " +
               "></span>" +
               item.displayLabel +
           "</a>" );

       leftListOfMainMenus += "</div>";

       document.getElementById("topMenuContainer").innerHTML = "" + theSearchInput +
           "<div class=\"row\" style=\"overflow: auto;height: inherit;\" >" +
               "<div class=\"col-xs-2 top-menu-option-chosen-left-container\" >" +
                   "<div " +
                           "class=\"top-menu-option-chosen-go-back\" " +
                           "onclick=\"javascript:loadMenu()\" " +
                           "onKeyDown=\"preLoadMenu(event)\" " +
                           "tabindex=\"0\" " +
                           "id=\"topMenuLeftBackButton\" " +
                   ">" +
                     "<span class=\"glyphicon glyphicon-backward top-menu-option-go-back-img\"></span>" +
                   "</div>" +
                   leftListOfMainMenus +
               "</div>" +
               "<div class=\"col-xs-10 top-menu-option-chosen-right-container container\" id=\"topMenuRightSideContainer\" >" +
                   "<div class=\"row text-left\" >" +
                       getDisplaySubOptionsRightSide(index) +
                   "</div>" +
               "</div>" +
           "</div>";
       document.getElementById("topMenuSearchConfig").style.display = "none";
       if ( document.getElementById("topMenuLeftOptionItem" + index) )
           document.getElementById("topMenuLeftOptionItem" + index).focus();
       else if ( document.getElementById("topMenuLeftBackButton") )
           document.getElementById("topMenuLeftBackButton").focus();*/
    changeColor(colorMenu);
}

let subNodesOnRightSideCounter;
let firstFocusableCountedOnRightSide;
function getDisplaySubOptionsRightSide(index) {

    let rightSideContainerContent = "";

    subNodesOnRightSideCounter = 0;
    firstFocusableCountedOnRightSide = -1;
    let fullListOfSubNodes = getFullListOfSubNodes(menuItems[index], 2, -1);

    fullListOfSubNodes.forEach(item => rightSideContainerContent += "" + item);
    changeColor(colorMenu);
    return rightSideContainerContent;
}

let previousLeftItemSelected = -1;
let currentLeftItemSelected = -1;
function rightDisplaySubOptions(outerIndex) {

    previousLeftItemSelected = currentLeftItemSelected;
    if (previousLeftItemSelected >= 0) {
        let itemAnchor = $("#topMenuLeftOptionItem" + previousLeftItemSelected);
        let itemIcon = $("#topMenuLeftOptionItem" + previousLeftItemSelected + " > span").first();
        itemAnchor.removeClass("top-menu-left-container-item-selected");
        itemAnchor.addClass("top-menu-left-container-item");
        itemIcon.removeClass("top-menu-left-container-img-selected");
        itemIcon.addClass("top-menu-left-container-img");
    }

    currentLeftItemSelected = outerIndex;
    let itemAnchor = $("#topMenuLeftOptionItem" + currentLeftItemSelected);
    let itemIcon = $("#topMenuLeftOptionItem" + currentLeftItemSelected + " > span").first();
    itemAnchor.removeClass("top-menu-left-container-item");
    itemAnchor.addClass("top-menu-left-container-item-selected");
    itemIcon.removeClass("top-menu-left-container-img");
    itemIcon.addClass("top-menu-left-container-img-selected");

    document.getElementById("topMenuRightSideContainer").innerHTML = "" +
        "<div class=\"row text-left\" >" +
        getDisplaySubOptionsRightSide(outerIndex) +
        "</div>";


}

function beforeGoMenuUrl(id, path, preventTogglingTopMenu, shouldTriggerTheClickMark, openMenu, goUrl) {


    if (isOpeningInAnewTab) {
        isOpeningInAnewTab = false;
        return;
    }

    var num=id.toString();
     if (openMenu && urlMap.get(num)) {


            Nav2.open(urlMap.get(num)[0], urlMap.get(num)[1]);

            setTimeout(function () {
                Nav2.close();
            }, 123);

        }

         if (goUrl && urlMap.get(num)) {


                    Nav2.open(urlMap.get(num)[0], urlMap.get(num)[1]);


                }

    emptyTopMenuSearch();
    if (!preventTogglingTopMenu)
        toggleMenu();
    let frameObject = document.getElementById("content");
    frameObject.src = 'common/menuRedirect.jsp?id=' + id + '&url=' + encodeURIComponent(path);

    if (shouldTriggerTheClickMark) {
        markItemAsClickedOrSelected(id);
    }
    $(".top-menu-last-selected-cell").removeClass("top-menu-last-selected-cell");
    $("#linkToPageTag" + id).addClass("top-menu-last-selected-cell");
    let nodesFromRootToLeaf = getDirectParentNodesFromLeafToRootBasedOnLeafId(menuItems, id);
    document.getElementById("topMenuCurrentLocationLabel").innerHTML = getFullPathForTopMenuLoadedItem(nodesFromRootToLeaf,id);


}

function getFullPathForTopMenuLoadedItem(theObject,id) {
    let stringToReturn = theObject.nodeDisplayLabel;
      let objectTemp=theObject;
    while (theObject.innerNodeFound) {

        theObject = theObject.innerNodeFound;
        stringToReturn += " > " + ((theObject.nodeDisplayLabel)
          /*  ?  ("<a href=\"javascript:beforeGoMenuUrl(" + theObject.nodeId + ", '" +  theObject.nodePath + "', false, false,false,true)\" > " + theObject.nodeDisplayLabel + "</a>" )
            : theObject.displayLabel);*/
            ? ("<a href=\"javascript:openMenu(" +  theObject.nodeId  + ")\" > " + theObject.nodeDisplayLabel + "</a>" )
            :  ("<a href=\"javascript:openMenu(" +  id + ")\" > " + theObject.displayLabel + "</a>" ));
    }
    return stringToReturn;

}
function openMenu(id){
Nav2.close();
 var num=id.toString();

        if ( urlMap.get(num))
         Nav2.open(urlMap.get(num)[0], urlMap.get(num)[1]);

}

let isOpeningInAnewTab = false;
function menuURLinNewTab(theEvent, id, path) {
    isOpeningInAnewTab = true;


    openLinkInAnewTab(id, path);


    //toggleMenu();
}

function getFullListOfSubNodes(parentNode, headersLevel, childNodeIndex) {

    subNodesOnRightSideCounter++;

    let headersContainerStyle = (headersLevel == 2)
        ? " style=\"position: absolute; " +
        "width: 79.8%;" +
        "background-color: #FFFFFF;" +
        "z-index: 888;" +
        "margin-top: -55px;" +
        "text-align: center;\" "
        : (headersLevel == 3)
            ? " style=\"overflow: hidden;\" "
            : " style=\"padding-left: " + ((headersLevel - 3) * 50) + "px;" +
            "overflow: hidden;\" ";

    let levelTwoLinksContainer = (headersLevel == 3 && childNodeIndex == 0)
        ? "</div>" +
        "<div class=\"row text-left\" style=\"margin-top: 48px;\" >"
        : "";

    let amountOfChildLeafNodes = countLeafNodes(parentNode.subMenu);

    let addCursorPointerToInnerHeader = (amountOfChildLeafNodes > 0)
        ? "cursor: pointer;"
        : "background-color: aliceblue;border-bottom:1px solid #E6F1F5;";
    let innerHeadersStyle = (headersLevel > 2)
        ? " style=\"" +
        addCursorPointerToInnerHeader +
        "display: block; margin-top: 5%;" +
        "\" "
        : " style=\"background-color: #FFFFFF;\" ";

    let headersImageStyle = (headersLevel < 3 || headersLevel > 5)
        ? ""
        : (headersLevel == 3)
            ? " style=\"font-size: 15px;float: left;top: 7px;\" "
            : (headersLevel == 4)
                ? " style=\"font-size: 12px;float: left;top: 4px;\" "
                : (headersLevel == 5)
                    ? " style=\"font-size: 9px;float: left;top: 3px;\" "
                    : "";

    let hideMostInnerLinks = (headersLevel > 3)
        ? " style=\"display: none;\" "
        : " style=\"display: block;\" ";

    let initialArrowClass = (headersLevel == 2)//3
        ? "glyphicon-chevron-down"
        : "glyphicon-chevron-right";

    let imageForHeader = (headersLevel > 2 && amountOfChildLeafNodes > 0)
        ? "<i class=\"glyphicon " + initialArrowClass + "\" " + headersImageStyle + " ></i> "
        : "";

    let imageForMainHeader = (headersLevel == 2)
        ? "<span " +
        "class=\"glyphicon " +
        getIconByMenuId(parentNode.id) +
        " top-menu-option-right-container-header-img\" " +
        "></span>"
        : "";

    let toggleExpandFunction = (headersLevel > 2 && amountOfChildLeafNodes > 0)
        ? " onClick=\"toggleInnerMenu(" + parentNode.id + "," + headersLevel + ")\" " +
        " onKeyDown=\"preToggleInnerMenu(event, " +
        parentNode.id + "," +
        headersLevel + ", " +
        subNodesOnRightSideCounter + ")\" " +
        " tabindex=\"0\" "
        : "";

    let displayChildCount = (headersLevel > 2 && amountOfChildLeafNodes > 0)
        ? " (" + amountOfChildLeafNodes + ")"
        : "";

    if (childNodeIndex) {
        let closingRowTags = "";
    }

    let theDividerDiv = "<div class=\"col-xs-12 top-menu-right-container-divider\" ></div>";
    let innerDividerDiv = (childNodeIndex > 0 && childNodeIndex % 4 == 0)
        ? theDividerDiv
        : "";

    let initialTag = (parentNode.path)
        ? levelTwoLinksContainer + innerDividerDiv +
        "<a " +
        "href=\"javascript:beforeGoMenuUrl(" + parentNode.id + ", '" + parentNode.path + "', false, false)\" " +
        "onKeyDown=\"keyDownOnLinkToPageTag(event, " +
        subNodesOnRightSideCounter + ", " +
        parentNode.id + ", " +
        "'" + parentNode.path + "')\" " +
        "onKeyUp=\"keyUpOnLinkToPageTag(event)\" " +
        "id=\"linkToPageTag" + parentNode.id + "\" " +
        "class=\"list-group-item " +
        "top-menu-right-container-item " +
        "col-xs-3 " +
        "top-menu-remove-focus-outline " +
        "\" " +
        hideMostInnerLinks +
        ">" +
        parentNode.displayLabel +
        "<img src=\"images/openInNewTab.png\" " +
        "class=\"top-menu-img-open-in-new-tab-icon\" " +
        "onclick=\"menuURLinNewTab(event, " +
        parentNode.id + ", " +
        "'" + parentNode.path + "')\" > " +
        "</a>" +
        "<input type=\"hidden\" " +
        "id=\"linksToPagesContainersAndLinkTags" + subNodesOnRightSideCounter + "\" " +
        "value=\"linkToPageTag" + parentNode.id + "\" />"
        : theDividerDiv +
        "</div>" +
        "<div " +
        "class=\"row text-left\" " +
        "id=\"topMenuRowContainer" + parentNode.id + "\" " +
        headersContainerStyle +
        " >" +
        "<h" +
        headersLevel +
        innerHeadersStyle +
        toggleExpandFunction +
        " class=\"top-menu-option-chosen-right-container-header " +
        "top-menu-remove-focus-outline " +
        "\" " +
        "id=\"linkToPagesContainer" + parentNode.id + "\" " +
        ">" +
        imageForMainHeader +
        parentNode.displayLabel +
        displayChildCount +
        imageForHeader +
        "</h" + headersLevel + ">" +
        "<input type=\"hidden\" " +
        "id=\"linksToPagesContainersAndLinkTags" + subNodesOnRightSideCounter + "\" " +
        "value=\"linkToPagesContainer" + parentNode.id + "\" />";

    if (firstFocusableCountedOnRightSide < 0
        && (toggleExpandFunction != ""
            || parentNode.path)) {
        firstFocusableCountedOnRightSide = subNodesOnRightSideCounter;
    }

    let listOfSubNodes = [initialTag];

    parentNode.subMenu.forEach((item, index) => {

        let innerListOfSubNodes = getFullListOfSubNodes(item, (headersLevel + 1), index);

        innerListOfSubNodes.forEach(item => listOfSubNodes.push(item));

    });

    if (parentNode.subMenu.length > 0) listOfSubNodes.push("");



    return listOfSubNodes;

}

function countLeafNodes(nodeToEvaluate) {
    let leafNodesCounter = 0;
    nodeToEvaluate.forEach(item => leafNodesCounter += (item.path) ? 1 : 0);
    return leafNodesCounter;
}

function preToggleInnerMenu(theEvent, innerMenuId, headersLevel, nodeCounterValue) {
    switch (theEvent.keyCode) {
        case 13://enter
            toggleInnerMenu(innerMenuId, headersLevel);
            break;
        case 37://left
            theEvent.preventDefault();
            if (nodeCounterValue == firstFocusableCountedOnRightSide)
                document.querySelector(".top-menu-left-container-item-selected").focus();
            else
                goToNextOrPreviousAvailable(nodeCounterValue, -1);
            break;
        case 38://up
            theEvent.preventDefault();
            goToNextOrPreviousAvailable(nodeCounterValue, -1);
            break;
        case 39://right
            theEvent.preventDefault();
            goToNextOrPreviousAvailable(nodeCounterValue, 1);
            break;
        case 40://down
            theEvent.preventDefault();
            goToNextOrPreviousAvailable(nodeCounterValue, 1);
            break;
    }
}

let currentlyPressedKeyOnLinkToPageTag = { 18: false, 13: false };
function keyUpOnLinkToPageTag(theEvent) {
    switch (theEvent.keyCode) {
        case 13://enter
            theEvent.preventDefault();
            currentlyPressedKeyOnLinkToPageTag[13] = false;
            break;
        case 18://Alt
            theEvent.preventDefault();
            currentlyPressedKeyOnLinkToPageTag[18] = false;
            break;
    }
}

function openLinkInAnewTab(itemId, itemPath) {
    let getUrl = window.location;
    let baseUrl = getUrl.protocol + "//" + getUrl.host + "/" + getUrl.pathname.split('/')[1] + "/main.jsp";
    let theBlankForm = document.getElementById("theBlankForm");
    theBlankForm.action = baseUrl;
    document.getElementById("idForPostInNewWindow").value = itemId;
    document.getElementById("pathForPostInNewWindow").value = itemPath;
    theBlankForm.submit();

}

function keyDownOnLinkToPageTag(theEvent, nodeCounterValue, itemId, itemPath) {
    switch (theEvent.keyCode) {
        case 13://enter
            theEvent.preventDefault();
            currentlyPressedKeyOnLinkToPageTag[13] = true;
            if (currentlyPressedKeyOnLinkToPageTag[18]) {
                openLinkInAnewTab(itemId, itemPath);
            }
            else
                beforeGoMenuUrl(itemId, itemPath, false, false);
            break;
        case 18://Alt
            theEvent.preventDefault();
            currentlyPressedKeyOnLinkToPageTag[18] = true;
            break;
        case 37://left
            theEvent.preventDefault();
            if (nodeCounterValue == firstFocusableCountedOnRightSide)
                document.querySelector(".top-menu-left-container-item-selected").focus();
            else
                goToNextOrPreviousAvailable(nodeCounterValue, -1);
            break;
        case 38://up
            theEvent.preventDefault();
            if (nodeCounterValue == firstFocusableCountedOnRightSide
                && document.getElementById("topMenuSearchInputField"))
                document.getElementById("topMenuSearchInputField").focus();
            else
                goToNextOrPreviousAvailable(nodeCounterValue, -4);
            break;
        case 39://right
            theEvent.preventDefault();
            goToNextOrPreviousAvailable(nodeCounterValue, 1);
            break;
        case 40://down
            theEvent.preventDefault();
            goToNextOrPreviousAvailable(nodeCounterValue, 4);
            break;
    }
}

function goToNextOrPreviousAvailable(nodeCounterValue, incrementalDecrementalValue) {

    let theNextDisplayedValue;

    let currentNodeCounterValue = nodeCounterValue;
    while (!theNextDisplayedValue
        && currentNodeCounterValue >= 0
        && currentNodeCounterValue <= subNodesOnRightSideCounter) {

        if (incrementalDecrementalValue == 1 || incrementalDecrementalValue == -1) {
            //choose the first found, immediately after or before
            currentNodeCounterValue += incrementalDecrementalValue;

            if (document.getElementById("linksToPagesContainersAndLinkTags" + currentNodeCounterValue)) {

                let theTagId = document.getElementById("linksToPagesContainersAndLinkTags" +
                    currentNodeCounterValue).value;

                let theTagElement = document.getElementById(theTagId);

                if (theTagElement && (theTagElement.style.display === "block"
                    || theTagElement.style.display == "")
                    && theTagElement.tabIndex >= 0) {
                    theNextDisplayedValue = currentNodeCounterValue;
                }
            }
        }
        else {
            //choose either the the "x"th link-tag (before or after) or the FIRST header found while looking...
            let startingNodeCounterValue = currentNodeCounterValue;
            let modIncrementalDecrementalValue = incrementalDecrementalValue / Math.abs(incrementalDecrementalValue);
            while (Math.abs(currentNodeCounterValue - startingNodeCounterValue) < Math.abs(incrementalDecrementalValue)
                && !theNextDisplayedValue
                && currentNodeCounterValue >= 0
                && currentNodeCounterValue <= subNodesOnRightSideCounter) {

                currentNodeCounterValue += modIncrementalDecrementalValue;

                if (document.getElementById("linksToPagesContainersAndLinkTags" + currentNodeCounterValue)) {

                    let theTagId = document.getElementById("linksToPagesContainersAndLinkTags" +
                        currentNodeCounterValue).value;

                    let theTagElement = document.getElementById(theTagId);

                    if (theTagElement && (theTagElement.style.display === "block"
                        || theTagElement.style.display == "")
                        && theTagElement.tabIndex >= 0
                        && (theTagId.startsWith("linkToPagesContainer")
                            || Math.abs(currentNodeCounterValue - startingNodeCounterValue)
                            == Math.abs(incrementalDecrementalValue))) {
                        theNextDisplayedValue = currentNodeCounterValue;
                    }
                }
            }
        }

    }

    if (document.getElementById("linksToPagesContainersAndLinkTags" + theNextDisplayedValue)) {

        let theNextNodeId = document.getElementById("linksToPagesContainersAndLinkTags" + theNextDisplayedValue).value;

        if (document.getElementById(theNextNodeId)) {

            document.getElementById(theNextNodeId).focus();

        }
    }
}

function toggleInnerMenu(innerMenuId, headersLevel) {

    toggleInnerLinksToPagesDisplay(innerMenuId);

    if ($("#topMenuRowContainer" + innerMenuId + " > h" + headersLevel + " > i").first().hasClass("glyphicon-chevron-right")) {
        $("#topMenuRowContainer" + innerMenuId + " > h" + headersLevel + " > i").removeClass("glyphicon-chevron-right");
        $("#topMenuRowContainer" + innerMenuId + " > h" + headersLevel + " > i").addClass("glyphicon-chevron-down");
    }
    else {
        $("#topMenuRowContainer" + innerMenuId + " > h" + headersLevel + " > i").removeClass("glyphicon-chevron-down");
        $("#topMenuRowContainer" + innerMenuId + " > h" + headersLevel + " > i").addClass("glyphicon-chevron-right");
    }

}

function toggleInnerLinksToPagesDisplay(innerMenuId) {

    let fullListOfSubMenusIds = getImmediateSubMenusBasedOnId(menuItems, innerMenuId)
        .filter(item => item.path)
        .map(item => item.id);

    fullListOfSubMenusIds.forEach(item => $("#linkToPageTag" + item).toggle(100));

}

function getImmediateSubMenusBasedOnId(arrayToEvaluate, innerMenuId) {
    let listFound = [];

    let i = 0;
    while (listFound.length <= 0 && i < arrayToEvaluate.length) {
        listFound = (arrayToEvaluate[i].id == innerMenuId)
            ? arrayToEvaluate[i].subMenu
            : getImmediateSubMenusBasedOnId(arrayToEvaluate[i].subMenu, innerMenuId);
        i++;
    }

    return listFound;
}

function preSearchMatchingMenuOption(theEvent, newValue) {
    searchMatchingMenuOption(newValue);

    if (theEvent.keyCode == 40) {
        if (document.getElementById("searchResult0"))
            document.getElementById("searchResult0").focus();
        else if (document.getElementById("topMenuLeftOptionItem0"))
            document.getElementById("topMenuLeftOptionItem0").focus();
        else if (document.getElementById("topMenuInitialIcons0"))
            document.getElementById("topMenuInitialIcons0").focus();
    }
}

function searchMatchingMenuOption(newValue) {

    let fullResultsList = searchForMenuItems(newValue, menuItems, "");


    let optionsToDisplay = "<ul > <div class=\"list-group\" style=\"margin-bottom: 0px; \" >";

    fullResultsList.forEach((item, index) => optionsToDisplay += "" +
         "<li >"+
        "<a " +
        "href=\"javascript:beforeGoMenuUrl(" + item.id + ", '" + item.path + "', false, true,true)\" " +
        "class=\"list-group-item top-menu-remove-focus-outline top-menu-right-container-item\" " +
        "style=\" font-size: medium; font-weight: bold;\" " +
        "id=\"searchResult" + index + "\" " +
        "onKeyDown=\"keyDownOnSearchResults(event, " + index + ", " + item.id + ", '" + item.path + "')\" " +
        "onKeyUp=\"keyUpOnLinkToPageTag(event)\" " +
        ">" +
        //  "(" + item.id + ") " +
        item.theRootPath + item.displayLabel +
        "<img src=\"images/openInNewTab.png\" " +
        "class=\"top-menu-img-open-in-new-tab-icon\" " +
        "onclick=\"menuURLinNewTab(event, " +
        item.id + ", " +
        "'" + item.path + "');emptyTopMenuSearch();\" > " +
        "</a> </li>");

    optionsToDisplay += "</div>  </ul >";

    document.getElementById("topMenuSearchResultsContainer").innerHTML = optionsToDisplay;

}
function keyDownOnSearchResults(theEvent, theCurrentIndex, itemId, itemPath) {
    switch (theEvent.keyCode) {
        case 13://enter
            theEvent.preventDefault();
            currentlyPressedKeyOnLinkToPageTag[13] = true;
            if (currentlyPressedKeyOnLinkToPageTag[18]) {
                openLinkInAnewTab(itemId, itemPath);
                emptyTopMenuSearch();
            }
            else {
                beforeGoMenuUrl(itemId, itemPath, false, true);
            }
            break;
        case 18://Alt
            theEvent.preventDefault();
            currentlyPressedKeyOnLinkToPageTag[18] = true;
            break;
        case 37://left
            theEvent.preventDefault();
            break;
        case 38://up
            theEvent.preventDefault();
            if (theCurrentIndex == 0 && document.getElementById("topMenuSearchInputField"))
                document.getElementById("topMenuSearchInputField").focus();
            else if (document.getElementById("searchResult" + (theCurrentIndex - 1)))
                document.getElementById("searchResult" + (theCurrentIndex - 1)).focus();
            break;
        case 39://right
            theEvent.preventDefault();
            break;
        case 40://down
            theEvent.preventDefault();
            if (document.getElementById("searchResult" + (theCurrentIndex + 1)))
                document.getElementById("searchResult" + (theCurrentIndex + 1)).focus();
            break;
    }
}

function emptyTopMenuSearch() {

    setTimeout(function () {
        if (document.getElementById("topMenuSearchResultsContainer")) {
            document.getElementById("topMenuSearchResultsContainer").innerHTML = "";
            document.getElementById("topMenuSearchInputField").value = "";
        }
    }, 1)

}

function searchForMenuItems(valueToSearch, arrayToEvaluate, theRootPath) {

    let itemsList = [];

    if (valueToSearch == "")
        return itemsList;

    arrayToEvaluate.forEach(item => {

        if (item.path && stringContainsAllElementsInArray(item.id, item.displayLabel, valueToSearch.split(" "))) {

            itemsList.push({
                id: item.id,
                displayLabel: item.displayLabel,
                path: item.path,
                theRootPath: theRootPath,
                menuLevel: item.menuLevel
            });
        }

        if (item.subMenu.length > 0) {
            let subItemsList = searchForMenuItems(valueToSearch, item.subMenu, theRootPath + item.displayLabel + " > ");
            subItemsList.forEach(item => itemsList.push(item));
        }

    });

    return itemsList;
}

function stringContainsAllElementsInArray(theId, theDisplayLabel, theArray) {

    let alteredDisplayLabel = theDisplayLabel.normalize('NFD').replace(/[\u0300-\u036f]/g, '');

    let i = 0;
    let response = (i < theArray.length) ? true : false;

    while (response && i < theArray.length) {

        let valueInTheArray = theArray[i].normalize('NFD').replace(/[\u0300-\u036f]/g, '');

        response = valueInTheArray == theId || alteredDisplayLabel.search(new RegExp(valueInTheArray, "i")) >= 0;

        i++;
    }

    return response;
}

function triggerShortCut(shortCutId) {
    if (shortCutId == 77) {
        toggleMenu();
    }
}

function markItemAsClickedOrSelected(itemId) {
    if (isOpeningInAnewTab) {
        isOpeningInAnewTab = false;
        return;
    }
    let theFoundObject = getDirectParentNodesFromLeafToRootBasedOnLeafId(menuItems, itemId);

    displaySubOptions(theFoundObject.nodeIndex);

    let lastNodeWithAnInnerItem = theFoundObject.innerNodeFound;
    while (lastNodeWithAnInnerItem.innerNodeFound && lastNodeWithAnInnerItem.innerNodeFound.innerNodeFound) {
        lastNodeWithAnInnerItem = lastNodeWithAnInnerItem.innerNodeFound;
    }

    toggleInnerMenu(lastNodeWithAnInnerItem.nodeId, (parseInt(lastNodeWithAnInnerItem.nodeMenuLevel) + 1));
}

function getDirectParentNodesFromLeafToRootBasedOnLeafId(arrayToSearch, theLeafId) {

    let nodeFound;

    arrayToSearch.forEach(
        (item, index) => {
            if (item.id == theLeafId) {
                nodeFound = item;
            }
            else {
                if (item.subMenu.length > 0) {
                    let innerNodeFound = getDirectParentNodesFromLeafToRootBasedOnLeafId(item.subMenu, theLeafId);
                    if (innerNodeFound) {
                        nodeFound = {
                            nodeId: item.id,
                            nodeIndex: index,
                            nodeDisplayLabel: item.displayLabel,
                            nodePath: item.path,
                            nodeMenuLevel: item.menuLevel,
                            innerNodeFound: innerNodeFound
                        };
                    }
                }
            }
        });

    return nodeFound;
}