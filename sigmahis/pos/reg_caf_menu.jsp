<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
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
	String compId=(String) session.getAttribute("_companyId");
	String id = request.getParameter("id");
	String fg = request.getParameter("fg");
	String tipo_pos = request.getParameter("tipo_pos");
	String key = "";
	String title = "";
	CommonDataObject cdo = new CommonDataObject();
	StringBuffer sbSql = new StringBuffer();

	if(mode==null) mode="add";
	if(fg==null) fg="";
	if(tipo_pos==null) tipo_pos="";
	if (change == null) change = "0";
	if (type == null) type = "0";
	
	htDet.clear();
	vDet.clear();

	if(request.getMethod().equalsIgnoreCase("GET")){
		if(mode.equalsIgnoreCase("add")) {
			title = "REGISTRAR";
			id = "";
			cdo.addColValue("id", "");
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("precio1", "0");
			cdo.addColValue("precio2", "0");
			cdo.addColValue("precio3", "0");
			cdo.addColValue("precio4", "0");
			cdo.addColValue("precio5", "0");
			cdo.addColValue("precio6", "0");
			cdo.addColValue("precio7", "0");
			cdo.addColValue("precio8", "0");
		} else {
			title = "MODIFICAR";
			sbSql.append("select id, codigo, descripcion, id_familia, estado, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, precio7, precio8, tipo, es_menu_dia, precio1, precio2, precio3, precio4, precio5, precio6, nvl(es_combo_adicional, 'N') es_combo_adicional, combo_colaborador, item_decoration from tbl_caf_menu where id = ");
			sbSql.append(id);

			if (id == null) throw new Exception("El Parametro no es válido. Por favor intente nuevamente!");
			cdo = SQLMgr.getData(sbSql.toString());

			sbSql = new StringBuffer();
			sbSql.append("select a.id_menu, a.id, a.id_articulo, a.comentario, b.descripcion, b.other3 afecta_inventario, a.cantidad from tbl_caf_menu_det a, tbl_inv_articulo b where a.id_articulo = b.cod_articulo and a.id_menu = ");
			sbSql.append(id);
			
			al = SQLMgr.getDataList(sbSql.toString());

			key = "";
			int ln = 0;
			for (int i=0; i<al.size(); i++){
				CommonDataObject det = (CommonDataObject) al.get(i);
				try {
					ln++;
					if (ln < 10) key = "00"+ln;
					else if (ln < 100) key = "0"+ln;
					else key = ""+ln;
	
					htDet.put(key, det);
					vDet.addElement(det.getColValue("id_articulo"));
					System.out.println("Add item...");
				} catch(Exception e) {
					System.out.println("Unable to add item...");
				}
			}

		}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
null;
}

function doSubmit(valor){
    document.form1.baction.value = valor;
    
    var checkedVals = $('input[type="checkbox"].tipo:checked').map(function() {
        return this.value;
    }).get().join(",");
    $("#tipo").val(checkedVals);
       
    window.frames['iFramereg_caf_menu_det'].doSubmit(valor);
}

$(document).ready(function(){
  var tipo = "<%=cdo.getColValue("tipo","")%>";
  
  var tipoA = tipo.split(",");
  $.each(tipoA, function (index, value) {
    $('input[type="checkbox"].tipo[value="' + value + '"]').prop("checked", true);
  });

});
</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
    <jsp:param name="title" value=""></jsp:param>
</jsp:include>
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tipo_pos",tipo_pos)%>
<%=fb.hidden("usuario_creacion",cdo.getColValue("usuario_creacion"))%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow02">
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td align="right">C&oacute;digo:</td>
					<td><%=fb.textBox("codigo", cdo.getColValue("codigo"), true, false, false, 50, 40, "text12", "", "", "", false, "", "")%></td>
					<td align="right">Descripci&oacute;n:</td>
					<td><%=fb.textBox("descripcion", cdo.getColValue("descripcion"), true, false, false, 50, 200, "text12", "", "", "", false, "", "")%></td>
				</tr>
				<%if(tipo_pos.equals("CAF")){%>
				<tr class="TextRow01">
					<td align="right">Es menu del d&iacute;a:</td>
					<td><%=fb.select("es_menu_dia", "Y=Si,N=No", cdo.getColValue("es_menu_dia"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
					<td align="right">Control Art&iacute;culo por Turno?</td>
					<td><%=fb.select("combo_colaborador", "Y=Si,N=No", cdo.getColValue("combo_colaborador"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right">Tipo:</td>
					<td><%//=fb.select("tipo", "D=Desayuno,A=Almuerzo,C=Cena,B=Almuerzo y Cena", cdo.getColValue("tipo"), false, false, 0, "text12", "", "", "", "", "", "", "")%>
                    <%=fb.hidden("tipo","")%>
                    
                    <%=fb.checkbox("desayuno", "D", false, false, "text12 tipo", "", "")%><label for="desayuno" class="pointer">Desayuno</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <%=fb.checkbox("almuerzo", "A", false, false, "text12 tipo", "", "")%><label for="almuerzo" class="pointer">Almuerzo</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <%=fb.checkbox("cena", "C", false, false, "text12 tipo", "", "")%><label for="cena" class="pointer">Cena</label>
                    </td>
					<td align="right">Es Combo Adicional:</td>
					<td><%=fb.select("es_combo_adicional", "N=No,S=Si", cdo.getColValue("es_combo_adicional"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
				</tr>
				<%} else {%>
				<%=fb.hidden("es_menu_dia", "N")%>
				<%=fb.hidden("tipo", "")%>
				<%=fb.hidden("es_combo_adicional", "N")%>
				<%}%>
				<tr class="TextRow01">
					<td align="right">Precio Normal:</td>
					<td><%=fb.decBox("precio1", CmnMgr.getFormattedDecimal(cdo.getColValue("precio1")), false, false, false, 12, 12.4, "text12", "", "", "", false, "", "")%></td>
					<td align="right">Precio Ejecutivo:</td>
					<td><%=fb.decBox("precio2", CmnMgr.getFormattedDecimal(cdo.getColValue("precio2")), false, false, false, 12, 12.4, "text12", "", "", "", false, "", "")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right">Precio Colaborador:</td>
					<td><%=fb.decBox("precio3", CmnMgr.getFormattedDecimal(cdo.getColValue("precio3")), false, false, false, 12, 12.4, "text12", "", "", "", false, "", "")%></td>
					<td align="right">Precio 4:</td>
					<td><%=fb.decBox("precio4", CmnMgr.getFormattedDecimal(cdo.getColValue("precio4")), false, false, false, 12, 12.4, "text12", "", "", "", false, "", "")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right">Precio 5:</td>
					<td><%=fb.decBox("precio5", CmnMgr.getFormattedDecimal(cdo.getColValue("precio5")), false, false, false, 12, 12.4, "text12", "", "", "", false, "", "")%></td>
					<td align="right">Precio 6:</td>
					<td><%=fb.decBox("precio6", CmnMgr.getFormattedDecimal(cdo.getColValue("precio6")), false, false, false, 12, 12.4, "text12", "", "", "", false, "", "")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right">Precio 7:</td>
					<td><%=fb.decBox("precio7", CmnMgr.getFormattedDecimal(cdo.getColValue("precio7")), false, false, false, 12, 12.4, "text12", "", "", "", false, "", "")%></td>
					<td align="right">Precio 8:</td>
					<td><%=fb.decBox("precio8", CmnMgr.getFormattedDecimal(cdo.getColValue("precio8")), false, false, false, 12, 12.4, "text12", "", "", "", false, "", "")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right">Familia:</td>
					<td><%=fb.select(ConMgr.getConnection(),"SELECT cod_flia, nombre from tbl_inv_familia_articulo where compania = "+(String) session.getAttribute("_companyId"),"id_familia",cdo.getColValue("id_familia"),false,false,0,"S")%></td>
					<td align="right">Estado:</td>
					<td><%=fb.select("estado", "A=Activo,I=Inactivo", cdo.getColValue("estado"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
                    </tr>
                    
                    <tr class="TextRow01">
					<td align="right">Colores:</td>
					<td colspan="3">Fondo y Texto&nbsp;<%=fb.select("item_decoration","redBlack=Rojo y negro,redWhite=Rojo y blanco,greenBlack=Verde y negro,greenWhite=Verde y blanco,yellowBlack=Amarillo y negro, yellowWhite=Amarillo y blanco,blueBlack=Azul y negro, blueWhite=Azul y blanco,pinkBlack=Rosado y negro,pinkWhite=Rosado y blanco",cdo.getColValue("item_decoration"),false,false,0,"","","",null,"S")%></td>
                    </tr>
        <tr>
					<td colspan="4">
						<iframe name="iFramereg_caf_menu_det" id="iFramereg_caf_menu_det" frameborder="0" align="center" width="100%" height="73%" scrolling="no" src="../pos/reg_caf_menu_det.jsp?id=<%=cdo.getColValue("id")%>&mode=<%=mode%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
					Opciones de Guardar: 
					<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro 
					<%=fb.radio("saveOption","O",false,false,false)%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
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
    String errCode = request.getParameter("errCode");
    String errMsg = request.getParameter("errMsg");
    String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
    
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<%
if(errCode.equals("1")){
%>
    alert('<%=errMsg%>');
    window.opener.location = '<%=request.getContextPath()%>/pos/list_caf_menu.jsp?tipo_pos=<%=tipo_pos%>';
<%
    if (saveOption.equalsIgnoreCase("N")){
%>
    setTimeout('addMode()',500);
<%
    } else if (saveOption.equalsIgnoreCase("O")){
%>
    setTimeout('editMode()',500);
<%
    } else if (saveOption.equalsIgnoreCase("C")){
%>
    window.close();
<%
    }    
} else throw new Exception(errMsg);
%>
}

function addMode()
{
    window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=request.getParameter("fg")%>&tipo_pos=<%=request.getParameter("tipo_pos")%>';
}

function editMode()
{
    window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=request.getParameter("id")%>&fg=<%=request.getParameter("fg")%>&tipo_pos=<%=request.getParameter("tipo_pos")%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>
