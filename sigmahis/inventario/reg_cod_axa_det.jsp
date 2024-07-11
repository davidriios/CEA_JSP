<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="art" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="artKey" scope="session" class="java.util.Hashtable" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
boolean viewMode = false;
int lineNo = 0;

if(mode == null) mode = "add";
if(fp==null) fp="cod_axa";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	var fg				= document.form.fg.value;
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../inventario/sel_articles_axa.jsp?mode=<%=mode%>&fg='+fg+'&fp=<%=fp%>');
	<%
	}
	%>
	//newHeight();
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function getCodigo(i){
	abrir_ventana('../common/sel_cod_axa.jsp?fp=<%=fp%>&index='+i);
}

function doSubmit(){
	var size = <%=art.size()%>;
	var x = 0;
	var baction = document.form.baction.value;
	for(i=0;i<size;i++){
		if(eval('document.form.cod_hna'+i).value==''){
			x++;
			break;
		}
	}
	if(size>0 && x == 0){
		document.form.submit();
	} else if(size>0 && x > 0){
		if(confirm('Desea guardar los artículos sin Codigo Axa?')) document.form.submit();
	}
}

function setAudValues(i){
	parent.document.form1.usuario_creacion.value = eval('document.form.usuario_creacion'+i).value;
	parent.document.form1.fecha_creacion.value = eval('document.form.fecha_creacion'+i).value;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td colspan="5" align="right"><%=fb.submit("addArticles","Agregar Articulos",false,false,"", "", "")%></td>
</tr>
  <tr class="TextHeader02">
    <td colspan="3" align="center">&nbsp;Codigo del art&iacute;culo</td>
    <td rowspan="2" align="center">&nbsp;Descripci&oacute;n</td>
    <td rowspan="2" align="center">&nbsp;C&oacute;digo AXA</td>
  </tr>
  <tr class="TextHeader02">
  	<td>Familia</td>
  	<td>Clase</td>
  	<td>Art&iacute;culo</td>
	</tr>
  <%

if (art.size() > 0) al = CmnMgr.reverseRecords(art);

for (int i=0; i<art.size(); i++){
	key = al.get(i).toString();									  
	CommonDataObject ad = (CommonDataObject) art.get(key);

	String color = "";
	
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	boolean readonly = true;
%>
	<%=fb.hidden("art_familia"+i, ad.getColValue("art_familia"))%>
  <%=fb.hidden("art_clase"+i, ad.getColValue("art_clase"))%>
  <%=fb.hidden("cod_articulo"+i, ad.getColValue("cod_articulo"))%>
  <%=fb.hidden("descripcion"+i, ad.getColValue("descripcion"))%>
  <%=fb.hidden("usuario_creacion"+i, ad.getColValue("usuario_creacion"))%>
  <%=fb.hidden("fecha_creacion"+i, ad.getColValue("fecha_creacion"))%>
  <tr class="<%=color%>" align="center" onMouseOver="javascript:setAudValues(<%=i%>)">
    <td><%=ad.getColValue("art_familia")%></td>
    <td><%=ad.getColValue("art_clase")%></td>
    <td><%=ad.getColValue("cod_articulo")%></td>
    <td><%=ad.getColValue("descripcion")%></td>
    <td>
    <%=fb.button("codaxa"+i,"...",false,false,"text10", "", "onClick=\"javascript:getCodigo("+i+")\"")%>
		<%=fb.textBox("cod_hna"+i,ad.getColValue("cod_hna"),false, false, true, 10)%>
    <%=fb.textBox("desc_hna"+i,ad.getColValue("desc_hna"),false, false, true, 50)%>
    </td>
  </tr>
  <%
}
%>
</table>
<%=fb.hidden("keySize",""+art.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	
	art.clear();
	al.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("art_familia", request.getParameter("art_familia"+i));
		cdo.addColValue("art_clase", request.getParameter("art_clase"+i));
		cdo.addColValue("cod_articulo", request.getParameter("cod_articulo"+i));
		cdo.addColValue("descripcion", request.getParameter("descripcion"+i));
		if(request.getParameter("cod_hna"+i)!=null && !request.getParameter("cod_hna"+i).equals("")) cdo.addColValue("cod_hna", request.getParameter("cod_hna"+i));
		if(request.getParameter("desc_hna"+i)!=null && !request.getParameter("desc_hna"+i).equals("")) cdo.addColValue("desc_hna", request.getParameter("desc_hna"+i));
		if(request.getParameter("del"+i)==null){
			if(request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("Guardar")){
				CommonDataObject cdo2 = new CommonDataObject();
				cdo2.setTableName("tbl_inv_articulo");
				if(request.getParameter("cod_hna"+i)!=null && !request.getParameter("cod_hna"+i).equals("")) cdo2.addColValue("cod_hna", request.getParameter("cod_hna"+i));
				else cdo2.addColValue("cod_hna","");
				cdo2.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
				cdo2.addColValue("fecha_modif", "sysdate");
				cdo2.setWhereClause("compania = "+(String) session.getAttribute("_companyId")+" and cod_flia = "+request.getParameter("art_familia"+i)+" and cod_clase = "+request.getParameter("art_clase"+i)+" and cod_articulo = "+request.getParameter("cod_articulo"+i));
				al.add(cdo2);
			}
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
	
			try{
				art.put(key, cdo);
				artKey.put(cdo.getColValue("art_familia")+"-"+cdo.getColValue("art_clase")+"-"+cdo.getColValue("cod_articulo"), key);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		} else {
			dl = "1";
		}
	}

	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../inventario/reg_cod_axa_det.jsp?mode="+mode+ "&change=1&type=2");
		return;
	}

	if(request.getParameter("addArticles")!=null){
		response.sendRedirect("../inventario/reg_cod_axa_det.jsp?mode="+mode+"&change=1&type=1");
		return;
	}
	

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.updateList(al);
		ConMgr.clearAppCtx(null);
	}
	
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.window.location='<%=request.getContextPath()%>/inventario/reg_cod_axa.jsp';
	
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>