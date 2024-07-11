<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.pos.Cafeteria"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="CafMgr" scope="page" class="issi.pos.CafeteriaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDet" scope="session" class="java.util.Vector" />
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	SQLMgr.setConnection(ConMgr);
	CmnMgr.setConnection(ConMgr);
	CafMgr.setConnection(ConMgr);

	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);
	ArrayList al = new ArrayList();

	String creatorId = UserDet.getUserEmpId();

	String mode=request.getParameter("mode");
	String change=request.getParameter("change");
	String type=request.getParameter("type");
	String id = request.getParameter("id");
	String fg = request.getParameter("fg");
	String title = "";

	if(mode==null) mode="add";
	boolean viewMode = false;
	if(mode.equals("view")) viewMode=true;
	if(fg==null) fg="";
	if (change == null) change = "0";
	if (type == null) type = "0";
	String key = "";
	if(request.getMethod().equalsIgnoreCase("GET"))    {
		if (mode.equalsIgnoreCase("add") && change == null) htDet.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../common/sel_articles_cafeteria.jsp?mode=<%=mode%>&almacen=1');
	<%
	}
	%>
if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function doSubmit(valor){
	document.form1.baction.value = valor;
	document.form1.mode.value = parent.document.form1.mode.value;
	document.form1.id.value = parent.document.form1.id.value;
	document.form1.codigo.value = parent.document.form1.codigo.value;
	document.form1.descripcion.value = parent.document.form1.descripcion.value;
	document.form1.es_menu_dia.value = parent.document.form1.es_menu_dia.value;
	document.form1.estado.value = parent.document.form1.estado.value;
	document.form1.tipo.value = parent.document.form1.tipo.value;
	document.form1.combo_colaborador.value = parent.document.form1.combo_colaborador?parent.document.form1.combo_colaborador.value : "";
        
	document.form1.item_decoration.value = parent.document.form1.item_decoration?parent.document.form1.item_decoration.value : "";
	document.form1.usuario_creacion.value = parent.document.form1.usuario_creacion.value;
    
	document.form1.precio1.value = parent.document.form1.precio1.value;
	document.form1.precio2.value = parent.document.form1.precio2.value;
	document.form1.precio3.value = parent.document.form1.precio3.value;
	document.form1.precio4.value = parent.document.form1.precio4.value;
	document.form1.precio5.value = parent.document.form1.precio5.value;
	document.form1.precio6.value = parent.document.form1.precio6.value;
	document.form1.precio7.value = parent.document.form1.precio7.value;
	document.form1.precio8.value = parent.document.form1.precio8.value;
	document.form1.id_familia.value = parent.document.form1.id_familia.value;
	document.form1.es_combo_adicional.value = parent.document.form1.es_combo_adicional.value;
	if(parent.form1Validation()){
		parent.form1BlockButtons(false);
		document.form1.submit();
	}
}

</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("codigo", "")%>
<%=fb.hidden("descripcion", "")%>
<%=fb.hidden("es_menu_dia", "")%>
<%=fb.hidden("estado", "")%>
<%=fb.hidden("fecha_creacion", "")%>
<%=fb.hidden("fecha_modificacion", "")%>
<%=fb.hidden("id", "")%>
<%=fb.hidden("id_familia", "")%>
<%=fb.hidden("precio1", "")%>
<%=fb.hidden("precio2", "")%>
<%=fb.hidden("precio3", "")%>
<%=fb.hidden("precio4", "")%>
<%=fb.hidden("precio5", "")%>
<%=fb.hidden("precio6", "")%>
<%=fb.hidden("precio7", "")%>
<%=fb.hidden("precio8", "")%>
<%=fb.hidden("tipo", "")%>
<%=fb.hidden("es_combo_adicional", "")%>
<%=fb.hidden("usuario_creacion", "")%>
<%=fb.hidden("combo_colaborador", "")%>
<%=fb.hidden("item_decoration", "")%>
<%=fb.hidden("keySize", ""+htDet.size())%>
<table align="center" width="100%">
	<tr>
		<td>
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
				<tr class="TextPanel">
					<td colspan="6" align="right"><%=fb.button("addAgregar","Agregar",false,viewMode, "", "", "onClick=\"javascript:doSubmit(this.value);\"")%></td>
				</tr>
				<tr class="TextHeader">
					<td width="10%" align="center">Art&iacute;culo</td>
					<td width="42%" align="left">Nombre</td>
					<td width="35%" align="left">Comentario</td>
					<td width="10%" align="left">Afecta Inventario</td>
					<td width="10%" align="left">Cantidad</td>
					<td width="3%">&nbsp;</td>
				</tr>
				<%
				key = "";
				if (htDet.size() != 0) al = CmnMgr.reverseRecords(htDet);
				for (int i=0; i<htDet.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) htDet.get(key);
					String color = "";
					if (i%2 == 0) color = "TextRow02";
					else color = "TextRow01";
				%>
				<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("id_menu"+i,cdo.getColValue("id_menu"))%>
				<%=fb.hidden("id_articulo"+i,cdo.getColValue("id_articulo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<%=fb.hidden("afecta_inventario"+i,cdo.getColValue("afecta_inventario"))%>
				<%=fb.hidden("almacen"+i,cdo.getColValue("almacen"))%>
				<tr class="<%=color%>" align="center">
					<td align="center"><%=cdo.getColValue("id_articulo")%></td>
					<td align="left"><%=cdo.getColValue("descripcion")%></td>
					<td align="left"><%=fb.textBox("comentario"+i, cdo.getColValue("comentario"), false, false, false, 50, 200, "text12", "", "", "", false, "", "")%></td>
					<td align="center"><%=(cdo.getColValue("afecta_inventario").equals("N")?"No":"Si")%></td>
					<td align="left"><%=fb.intBox("cantidad"+i, cdo.getColValue("cantidad"), false, false, false, 5, 4, "text12", "", "", "", false, "", "")%></td>
					<td width="3%" align="center"><%=fb.submit("del"+i,"X",false,false, "text10", "", "onClick=\"javascript:doSubmit(this.value);\"")%></td>
				</tr>
				<%}%>
			</table>
		</td>
  </tr>
</table>
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
} else if(request.getMethod().equalsIgnoreCase("post")) {
	String baction = request.getParameter("baction");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String del = "";
	Cafeteria _cdo = new Cafeteria();

	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	CommonDataObject cdo = new CommonDataObject();
	if(request.getParameter("es_menu_dia")!=null) cdo.addColValue("es_menu_dia", request.getParameter("es_menu_dia"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("tipo")!=null) cdo.addColValue("tipo", request.getParameter("tipo"));
	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id"));
	if(request.getParameter("id_familia")!=null) cdo.addColValue("id_familia", request.getParameter("id_familia"));
	if(request.getParameter("precio1")!=null) cdo.addColValue("precio1", request.getParameter("precio1"));
	if(request.getParameter("precio2")!=null) cdo.addColValue("precio2", request.getParameter("precio2"));
	if(request.getParameter("precio3")!=null) cdo.addColValue("precio3", request.getParameter("precio3"));
	if(request.getParameter("precio4")!=null) cdo.addColValue("precio4", request.getParameter("precio4"));
	if(request.getParameter("precio5")!=null) cdo.addColValue("precio5", request.getParameter("precio5"));
	if(request.getParameter("precio6")!=null) cdo.addColValue("precio6", request.getParameter("precio6"));
	if(request.getParameter("precio7")!=null) cdo.addColValue("precio7", request.getParameter("precio7"));
	if(request.getParameter("precio8")!=null) cdo.addColValue("precio8", request.getParameter("precio8"));
	if(request.getParameter("codigo")!=null) cdo.addColValue("codigo", request.getParameter("codigo"));
	if(request.getParameter("descripcion")!=null) cdo.addColValue("descripcion", request.getParameter("descripcion"));
	if(request.getParameter("es_combo_adicional")!=null) cdo.addColValue("es_combo_adicional", request.getParameter("es_combo_adicional"));
	if(request.getParameter("usuario_creacion")!=null) cdo.addColValue("usuario_creacion", request.getParameter("usuario_creacion"));
	if(request.getParameter("combo_colaborador")!=null) cdo.addColValue("combo_colaborador", request.getParameter("combo_colaborador"));
	if(request.getParameter("item_decoration")!=null) cdo.addColValue("item_decoration", request.getParameter("item_decoration"));
	cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
    
	htDet.clear();
	vDet.clear();
	al = new ArrayList();
	int ln = 0;
	for(int i=0;i<keySize;i++){
		CommonDataObject det = new CommonDataObject();

    if(request.getParameter("comentario"+i)!=null) det.addColValue("comentario", request.getParameter("comentario"+i));
		if(request.getParameter("id"+i)!=null) det.addColValue("id", request.getParameter("id"+i));
		if(request.getParameter("id_articulo"+i)!=null) det.addColValue("id_articulo", request.getParameter("id_articulo"+i));
		if(request.getParameter("id_menu"+i)!=null) det.addColValue("id_menu", request.getParameter("id_menu"+i));
		if(request.getParameter("descripcion"+i)!=null) det.addColValue("descripcion", request.getParameter("descripcion"+i));
		if(request.getParameter("afecta_inventario"+i)!=null) det.addColValue("afecta_inventario", request.getParameter("afecta_inventario"+i));
		if(request.getParameter("cantidad"+i)!=null) det.addColValue("cantidad", request.getParameter("cantidad"+i));
		if(request.getParameter("almacen"+i)!=null) det.addColValue("almacen", request.getParameter("almacen"+i));

		if(request.getParameter("del"+i)==null){
			try {
				ln++;
				if (ln < 10) key = "00"+ln;
				else if (ln < 100) key = "0"+ln;
				else key = ""+ln;

				htDet.put(key, det);
				vDet.addElement(det.getColValue("id_articulo"));
				al.add(det);
				System.out.println("Add item...");
			} catch(Exception e) {
				System.out.println("Unable to add item...");
			}
		} else del = "1";
	}

	if(!del.equals("") || clearHT.equals("S")){
		response.sendRedirect("../pos/reg_caf_menu_det.jsp?mode="+mode+"&change=1&type=2&fg="+fg);
		return;
	}

	if(baction!=null && baction.equalsIgnoreCase("Agregar")){
		response.sendRedirect("../pos/reg_caf_menu_det.jsp?mode="+mode+"&change=1&type=1&fg="+fg);
		return;
	}
	if (mode.equalsIgnoreCase("add")){
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	} else {
		cdo.addColValue("fecha_modificacion", CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
	}
	_cdo.setCdo(cdo);
	_cdo.setAlDet(al);
    String returnId = "";
    if (baction!=null && baction.equalsIgnoreCase("Guardar")) {
			if (mode.equalsIgnoreCase("add")){
				
				CafMgr.addMenu(_cdo);
				returnId = CafMgr.getPkColValue("id");
			} else {
				returnId = request.getParameter("id");
				CafMgr.updMenu(_cdo);
			}
    }

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if(CafMgr.getErrCode().equals("1")){
%>
		parent.document.form1.errCode.value = <%=CafMgr.getErrCode()%>;
		parent.document.form1.errMsg.value = '<%=CafMgr.getErrMsg()%>';
		parent.document.form1.id.value = '<%=returnId%>';
    parent.document.form1.submit();
<%
} else throw new Exception(CafMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>
