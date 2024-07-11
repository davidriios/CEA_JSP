<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.Menu"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="com.google.gson.Gson"%>
<%@ page errorPage="error.jsp"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />

<%!
public String attachAndGetParentId(Menu menuToAdd, ArrayList<Menu> theFinalResultList){
    for (int i=0; i < theFinalResultList.size(); i++) {
        if( theFinalResultList.get(i).getId().equals(menuToAdd.getParentId()) ){
            //Parent found; add the child and return the parent-id
            theFinalResultList.get(i).getSubMenu().add(menuToAdd);
            return theFinalResultList.get(i).getId();
        }
        else{
            //if the node is NOT the parent and has sub-menus, look for the parent among those sub-menus
            if ( theFinalResultList.get(i).getSubMenu().size() > 0 ) {
                String foundParentIdAmongSubMenus = attachAndGetParentId(menuToAdd, theFinalResultList.get(i).getSubMenu());
                if ( !foundParentIdAmongSubMenus.equals("0") ) {
                    return foundParentIdAmongSubMenus;
                }
            }
        }
    }
    return "0";
}
%>

<%
SecMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

if (!UserDet.getUserProfile().contains("0")) {
	if (SecMgr.showPasswordChange(UserDet)) response.sendRedirect(request.getContextPath()+"/admin/user_preferences.jsp?fp=newpass&tab=1");
}

String msg = request.getParameter("msg");
if (msg == null) msg = "";
String furl = request.getParameter("furl");
if (furl == null) furl = "";


Gson gson = new Gson();
String outputString = "";
CommonDataObject cdo = new CommonDataObject();
String menuColor="";
String sql1 = "select param_value from TBL_SEC_COMP_PARAM where param_name= 'MENUHEX'";
cdo=SQLMgr.getData(sql1);
menuColor = gson.toJson(cdo.getColValue("param_value"));
if ( UserDet != null ){

    String optionalInStatement = ( UserDet.getUserProfile().contains("0") )
                                 ? ""
                                 : "id in ( " +
                                   "    SELECT menu_id " +
                                   "    FROM tbl_sec_profile_menu " +
                                   "    WHERE profile_id IN ( " +
                                               CmnMgr.vector2numSqlInClause(UserDet.getUserProfile()) +
                                   "    )  " +
                                   ") " +
                                   "AND ";
    String sql = "SELECT DISTINCT " +
                 "    id              AS id, " +
                 "    display_label   AS displayLabel, " +
                 "    display_order   AS displayOrder, " +
                 "    description     AS description, " +
                 "    path            AS path, " +
                 "    parent_id       AS parentId, " +
                 "    LEVEL           AS menuLevel " +
                 "FROM tbl_sec_menu " +
                 "WHERE " + optionalInStatement + "status = 'A' " +
                 "START WITH parent_id = 0 " +
                 "CONNECT BY PRIOR id = parent_id " +
                 "ORDER BY LEVEL, parent_id, id";

    SQL2BeanBuilder sbb = new SQL2BeanBuilder();
    ArrayList resultList = sbb.getBeanList(ConMgr.getConnection(),sql,Menu.class);

    ArrayList<Menu> finalResultList = new ArrayList<Menu>();
    for (int i=0; i < resultList.size(); i++) {

        Menu menu = (Menu) resultList.get(i);

        if( Integer.parseInt(menu.getMenuLevel()) == 1  ) {
            finalResultList.add(menu);
        }
        else {
            String parentIdFound = attachAndGetParentId(menu, finalResultList);
            if ( parentIdFound.equals("0") ){
                //option to add orphan child-nodes as root-level nodes
                    //This happens when a child-node is linked to any of the user's profiles and that child-node's parent-node is not.
                //finalResultList.add(menu);
            }
        }

    }

    outputString = gson.toJson(finalResultList);

}


%>
<html>
<head>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/bootstrap.min.css">
<%@ include file="common/nocache.jsp"%>
<%@ include file="common/header_param.jsp"%>
<script src="<%=request.getContextPath()%>/js/topMenuFunctions.js"></script>
<style type='text/css'>
@-moz-document url-prefix() {
	iframe { display: block; }
}
</style>
<!--[if gt IE 8]>
<style type="text/css">
	iframe { display: block; }
</style>
<![endif]-->
<script language="javascript">
let menuItems = <%=outputString%>;

let theIdForPostInNewWindow;
let thePathForPostInNewWindow;

let colorMenu = <%=menuColor%>;
<%
if ( request.getMethod().equalsIgnoreCase("POST") )
{
    if ( request.getParameter("idForPostInNewWindow") != null
                 && request.getParameter("pathForPostInNewWindow") != null ) {
        String theIdForPostInNewWindow = request.getParameter("idForPostInNewWindow");
        String thePathForPostInNewWindow = request.getParameter("pathForPostInNewWindow");
        %>
        theIdForPostInNewWindow = <%=theIdForPostInNewWindow%>;
        thePathForPostInNewWindow = '<%=thePathForPostInNewWindow%>';
        <%
    }
}
%>
document.title=""+document.title;
var xHeight=0;
function doAction(){var furl = '<%=furl.replace("|","&")%>';
if(furl!=''&& furl!='undefined'){ window.frames['content'].location = '<%=request.getContextPath()%>/'+furl;}
xHeight=objHeight('_tblMainHeader');resizeFrame();/*window.frames['unloadFrame'].location = '<%=request.getContextPath()%>/'+'unloadPageAfter.jsp';*/

}
function resizeFrame(){resetFrameHeight(window.frames['content'],xHeight,350,null,8);}
function closeSession(){abrir_ventana('logout.jsp?exit=yes');}
jQuery(document).ready(function(){doAction(); loadNav();});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="common/header.jsp"%>
<%@ include file="common/menu_base_main.jsp"%>
<div id="container"></div>
<iframe id="unloadFrame" name="unloadFrame" frameborder="0" width="100%" height="0" src="unloadPage.jsp" style="display:none"></iframe>
<iframe id="content" name="content" frameborder="0" width="100%" height="500" src="<%=(UserDet.getDefaultPage() == null || UserDet.getDefaultPage().trim().equals(""))?"common/menuRedirect.jsp?id=1138&url=..%2Fadmin%2Fapp_users.jsp":UserDet.getDefaultPage()%>"></iframe>

<%@ include file="common/footer.jsp"%>
<input type="hidden" id="_winTitle" name="_winTitle" value="<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>">
<form id="theBlankForm" style="display:none" target="_blank" method="POST" >
    <input type="hidden"
           id="idForPostInNewWindow"
           name="idForPostInNewWindow"
           value="420">
    <input type="hidden"
           id="pathForPostInNewWindow"
           name="pathForPostInNewWindow"
           value="../caja/list_recibo.jsp?tipoCliente=O">
</form>
</body>
</html>
