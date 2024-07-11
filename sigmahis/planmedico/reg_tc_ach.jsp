<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SolMgr" scope="page" class="issi.planmedico.SolicitudMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="tcDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vtcDet" scope="session" class="java.util.Vector"/>
<%
/**
==========================================================================================
FORMA OP_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SolMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String sql = "", key = "";
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String id = request.getParameter("id");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String tipo_trx = request.getParameter("tipo_trx");
String contrato = request.getParameter("num_contrato");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;

String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

if(fg==null) fg = "mat_paciente";
if(fp==null) fp = "";
String cDateTime = CmnMgr.getCurrentDate("mm/yyyy");
if(mes == null) mes =cDateTime.substring(0, 2);
if(anio == null) anio = cDateTime.substring(3, 7);

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	if (mode.equalsIgnoreCase("add")){
		cdo.addColValue("mes", mes);
		cdo.addColValue("anio", anio);
		cdo.addColValue("id", id);
		cdo.addColValue("tipo_trx", tipo_trx);
		tcDet.clear();
		vtcDet.clear();
	} else {
		if (id == null) throw new Exception("Id de transaccion no es válido. Por favor intente nuevamente!");

		if (change==null){
			tcDet.clear();
			vtcDet.clear();
			/*
			encabezado
			*/
			sql="";

			sbSql.append("select id, anio, lpad(mes, 2, '0') mes, tipo_trx, estado from tbl_pm_regtran where id = ");
			sbSql.append(id);
			cdo = SQLMgr.getData(sbSql.toString());
			if(cdo.getColValue("estado").equals("A") || cdo.getColValue("estado").equals("I")) viewMode = true;
			tipo_trx=cdo.getColValue("tipo_trx");
			sbSql = new StringBuffer();
			sbSql.append("select id, secuencia, id_contrato, id_cliente, (select nombre_paciente from vw_pm_cliente where codigo = a.id_cliente) nombre_cliente, estado, tipo_trx, monto, monto_app, id_corredor, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, periodo, num_cuotas, nvl(referencia, '') referencia, nvl(comentario, '') comentario from tbl_pm_regtran_det a where id = ");
			sbSql.append(id);
			sbSql.append(" order by id_contrato desc, id_cliente");
			al = SQLMgr.getDataList(sbSql.toString());
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				if ((i+1) < 10) key = "00"+(i+1);
				else if ((i+1) < 100) key = "0"+(i+1);
				else key = ""+(i+1);

				try {
					tcDet.put(key, cdoDet);
					vtcDet.addElement(cdoDet.getColValue("id_contrato")+"_"+cdoDet.getColValue("id_cliente"));
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
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
document.title = 'Cuentas x Pagar- '+document.title;

function doAction(){
}

function doSubmit(valor){
	window.frames['itemFrame']._doSubmit(valor);
}

function printReport(){
	var anio = document.contrato.anio.value;
	var mesDesc = getSelectedOptionLabel(document.contrato.mes, '1');
	var id = document.contrato.id.value;
	//abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_cxc_ach_tc.rptdesign&anioParam="+anio+"&mesParam="+mesDesc+"&idParam="+id);
	abrir_ventana("../planmedico/print_pm_ach_tc.jsp?anio="+anio+"&mesDesc="+mesDesc+"&idSol="+id+"&tipoTrx=<%=cdo.getColValue("tipo_trx")%>");
}
function chkReg(){
	var tipo_trx=document.contrato.tipo_trx.value;
	if(window.frames['itemFrame'].document.form1.keySize.value!=0) {
		if(confirm('Al cambiar el tipo de transaccion se borraran los registros agregados anteriormente, desea continuar?')){
			window.frames['itemFrame'].location='../planmedico/reg_tc_ach_det.jsp?mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&anio=<%=anio%>&mes=<%=mes%>&tipo_trx='+tipo_trx;
		}
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%fb = new FormBean("contrato",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("id",id)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
							<%=fb.hidden("fg",fg)%>
							<%=fb.hidden("codigo","")%>
							<tr>
								<td colspan="8" align="right"><authtype type='2'><a href="javascript:printReport()" class="btn_link">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a></authtype>
								</td>
							</tr>
							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>REGISTRO TRANSACCIONES DE ACH/TARJETA DE CREDITO</cellbytelabel></td>
							</tr>
							<tr class="TextFilter">
								<td align="left" colspan="8">
								A&ntilde;o: <%=fb.textBox("anio",cdo.getColValue("anio"),true,false,(!mode.equals("add")),5,4,"Text12","","")%>
								Mes: <%=fb.select("mes","01=Enero, 02=Febrero, 03=Marzo, 04=Abril, 05=Mayo, 06=Junio, 07=Julio, 08=Agosto, 09 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",cdo.getColValue("mes"),false,false,!mode.equals("add"),0,"Text12","","")%>
								Tipo:
								<%=fb.select("tipo_trx","ACH=ACH,TC=TARJETA DE CREDITO,M=MANUAL",cdo.getColValue("tipo_trx"),false,false,(!mode.equals("add")),0,"Text10","","onChange=\"javascript:chkReg();\"")%>
								<authtype type='6'>
								</authtype>
								</td>
							</tr>
              <tr>
                <td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="yes" src="../planmedico/reg_tc_ach_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&anio=<%=anio%>&mes=<%=mes%>&tipo_trx=<%=tipo_trx%>"></iframe></td>
              </tr>
							 <tr class="TextRow02">
								<td colspan="6" align="right"> 
								Opciones de Guardar: 
								<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel> 
								<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel> 
								<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
								<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript:doSubmit(this.value);\"")%> 
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> 
								</td>
							</tr>
           </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
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

	id = request.getParameter("id");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
	session.removeAttribute("tcDet");
	session.removeAttribute("tcDetKey");
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_cxc_ach_tc_list.jsp';
<%
if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
