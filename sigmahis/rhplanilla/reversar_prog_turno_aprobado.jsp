<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
emp.clear();
empKey.clear();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");

if(fg==null) fg = "";
if(grupo==null) grupo = "";
if(area==null) area = "";
if(fp==null) fp = "";
if(anio==null) anio = "";
if(mes==null) mes = "";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
	if(!anio.equals("") && !mes.equals("")){
		System.out.println("in....................");
		sql = "select c.codigo, c.codigo||'-'||c.descripcion descripcion from tbl_pla_ct_tprograma a, tbl_pla_ct_empleado b, tbl_pla_ct_grupo c where a.emp_id = b.emp_id and b.grupo = c.codigo and b.compania = c.compania and a.anio = "+anio+" and a.mes = "+mes+" and a.compania = "+(String) session.getAttribute("_companyId")+" and a.aprobado = 'S'";
		cdo = SQLMgr.getData(sql);
		if(cdo==null) cdo = new CommonDataObject();
		grupo = cdo.getColValue("codigo");
	}
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'RRHH - '+document.title;

function doSubmit(value){
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}


function doAction(){
	setTextValues();
	setHeight('itemFrame',document.body.scrollHeight);
}

function imprimir(){
	abrir_ventana('../inventario/print_list_articulos_axa.jsp');
}

function setValues(){
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	if(anio!='' && mes !=''){
		var sql = '(case when to_date('+mes+' || \'/\' || '+anio+', \'mm/yyyy\') >= to_date(to_char(sysdate, \'mm/yyyy\'), \'mm/yyyy\') then 1 else 0 end)';
		sql = getDBData('<%=request.getContextPath()%>',sql,'dual','','');
		if(sql==1) window.location = '../rhplanilla/reversar_prog_turno_aprobado.jsp?anio='+anio+'&mes='+mes+'&fp=<%=fp%>';
		else alert('No es posible REVERSAR el programa de meses pasados, sólo el del mes ACTUAL y POSTERIOR');
		window.location = '../rhplanilla/reversar_prog_turno_aprobado.jsp?anio='+anio+'&mes='+mes+'&fp=<%=fp%>';
	}
}

function setTextValues(){
	//window.frames['itemFrame'].setTextValues();
	var uf_codigo = document.form1.uf_codigo.value;
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	var grupo = document.form1.grupo.value;
	if(anio!='' && mes !=''){
	window.frames['itemFrame'].location = '../rhplanilla/reversar_prog_turno_aprob_det.jsp?grupo='+grupo+'&uf_codigo='+uf_codigo+'&anio='+anio+'&mes='+mes+'&fp=<%=fp%>';
	}
}

function showHideTD(x){
	if(x=='2'){
		window.frames['itemFrame'].document.getElementById('col_1_15').style.display = 'none';
		window.frames['itemFrame'].document.getElementById('col_16_31').style.display = '';
	} else {
		window.frames['itemFrame'].document.getElementById('col_1_15').style.display = '';
		window.frames['itemFrame'].document.getElementById('col_16_31').style.display = 'none';
	}
}

function reversar(){
	if(document.form1.grupo.value!='' && window.frames['itemFrame'].document.getElementById('keySize')!=0) window.frames['itemFrame'].reversar('all');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                    <%=fb.formStart(true)%> 
										<%=fb.hidden("mode",mode)%> 
										<%=fb.hidden("errCode","")%> 
										<%=fb.hidden("errMsg","")%> 
										<%=fb.hidden("baction","")%> 
										<%=fb.hidden("fg",fg)%> 
										<%=fb.hidden("fp",fp)%> 
										<%=fb.hidden("clearHT","")%> 
                    <%=fb.hidden("fecha_inicio","")%>
                    <%=fb.hidden("fecha_final","")%>
                    <%=fb.hidden("finicio","")%>
                    <%=fb.hidden("ffinal","")%>
                    <%=fb.hidden("num_periodo","")%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextPanel">
                            <td>&nbsp;
                            A&ntilde;o
														<%=fb.textBox("anio",anio,false,false,false,4,"text10","","onChange=\"javascript:setValues()\"")%>
                            Mes
														<%=fb.select("mes","01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre",mes, false, false, 0, "text10", "", "onChange=\"javascript:setValues()\"", "", "S")%>
                            </td>
                            <td>&nbsp;</td>
                          </tr>
                          <tr class="TextPanel">
                            <td>&nbsp;
                            Grupo:
                            <%
														if(!anio.equals("") && !mes.equals("")){
															sql = "select distinct c.codigo, c.codigo||'-'||c.descripcion from tbl_pla_ct_tprograma a, tbl_pla_ct_empleado b, tbl_pla_ct_grupo c where a.emp_id = b.emp_id and b.grupo = c.codigo and b.compania = c.compania and a.anio = "+anio+" and a.mes = "+mes+" and a.compania = "+(String) session.getAttribute("_companyId")+" and a.aprobado = 'S'";
                            } else {
															sql = "select '' codigo, 'Seleccione' descripcion from dual";
														}
														%>
														<%=fb.select(ConMgr.getConnection(),sql,"grupo",grupo,false,false,0,"text10",null,"onChange=\"javascript:loadXML('../xml/areaXGrupo.xml','uf_codigo','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','')\"")%>
                            &nbsp;
                            <%=fb.button("rever","Revertir",false,false,"text10","","onClick=\"javascript:reversar();\"")%>
                            &nbsp;
                            Ubic. o Area de Trab.
														<%=fb.select("uf_codigo","","",false,false,0, "text10", "", "onChange=\"javascript:clearTextBox();\"")%>
														<script language="javascript">
														loadXML('../xml/areaXGrupo.xml','uf_codigo','<%=area%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")+"-"+grupo%>','KEY_COL','0');
                            </script>
                            <%=fb.button("ir","Ir",false,false,"text10","","onClick=\"javascript:setTextValues();\"")%>
                            </td>
                            <td>&nbsp;</td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../rhplanilla/reversar_prog_turno_aprob_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>"></iframe></td>
                    </tr>
                    <%=fb.formEnd(true)%>
                    <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                  </table></td>
              </tr>
            </table></td>
        </tr>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
	if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>	
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&grupo=<%=grupo%>&area=<%=area%>&anio=<%=request.getParameter("anio")%>&mes=<%=request.getParameter("mes")%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
