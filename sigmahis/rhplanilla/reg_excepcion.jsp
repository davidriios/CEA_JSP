<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.Horario"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" 		scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" 		scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" 	scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="HorDet" scope="session" class="issi.rhplanilla.Horario" />
<jsp:useBean id="CmnMgr" 		scope="page" 		class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" 		scope="page" 		class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" 				scope="page" 		class="issi.admin.FormBean" />
<jsp:useBean id="cdo" 			scope="page" 		class="issi.admin.CommonDataObject" />
<%
/*
===============================================================================
===============================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
if(change==null) change="";

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Administración - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CREAR EXCEPCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
				<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
		<!-- ====================   F O R M   S T A R T   H E R E   ================ -->
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("action","")%>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>

				<tr class="TextRow02">
					<td colspan="4" align="right">&nbsp;</td>
				</tr>

				<tr class="TextRow01">
					<td colspan="4"><table align="center" width="99%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">

				<tr class="TextHeader">
					<td width="10%" align="center" colspan="2">&nbsp;</td>
					<td width="27%" align="center" colspan="3">ENTRADA</td>
					<td width="5%" align="center">Ver. Comida</td>
					<td width="18%" align="center" colspan="2">ALMUERZO</td>
					<td width="27%" align="center" colspan="3">SALIDA</td>
					<td width="13%" align="center" colspan="2">&nbsp;</td>
				</tr>

				<tr class="TextHeader">
					<td width="2%" align="center">Sec.</td>
					<td width="8%" align="center">D&iacute;a</td>
					<td width="9%" align="center">Desde</td>
					<td width="9%" align="center">Entrada</td>
					<td width="9%" align="center">Hora Gracia</td>
					<td width="5%" align="center">&nbsp;</td>
					<td width="9%" align="center">Salida</td>
					<td width="9%" align="center">Entrada</td>
					<td width="9%" align="center">Desde</td>
					<td width="9%" align="center">Salida</td>
					<td width="9%" align="center">Hasta</td>
					<td width="8%" align="center">Hras. Trab.</td>
					<td width="5%" align="center"><%=fb.submit("addCmn1","+",false,false,"","","onClick=\"javascript:document.form1.action.value='add'\"")%></td>
				</tr>

	<%
	String key = "";
	for (int i=0; i<HorDet.getExcepciones().size(); i++) {
		Horario ho = (Horario) HorDet.getExcepciones().get(i);
		String color = "TextRow02";
		String hora = "";
		if(ho.getHoraEntDesde()==null || ho.getHoraEntDesde().trim().equals("null"))ho.setHoraEntDesde("");
		if(ho.getHoraEnt()== null || ho.getHoraEnt().trim().equals("null")) ho.setHoraEnt("");
		if(ho.getHoraGraciaEnt()==null || ho.getHoraGraciaEnt().trim().equals("null"))ho.setHoraGraciaEnt("");
		if(ho.getHoraSalAlm()==null || ho.getHoraSalAlm().trim().equals("null"))ho.setHoraSalAlm("");
		if(ho.getHoraEntAlm()==null || ho.getHoraEntAlm().trim().equals("null"))ho.setHoraEntAlm("");
		if(ho.getHoraSalDesde()==null || ho.getHoraSalDesde().trim().equals("null"))ho.setHoraSalDesde("");
		if(ho.getHoraSal()==null || ho.getHoraSal().trim().equals("null"))ho.setHoraSal("");
		if(ho.getHoraSalHasta()==null || ho.getHoraSalHasta().trim().equals("null"))ho.setHoraSalHasta("");

			if (i % 2 == 0) color = "TextRow01";
					System.out.println("ho.getDias() = "+ho.getDias());
	%>
	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td><%=fb.textBox("secuencia"+i,ho.getSecuencia(),true,false,true,2,null,null,"")%></td>
	        <td>&nbsp;<%=fb.select("dias"+i,"L=Lun,M=Mar,W=Mier,J=Jue,V=Vier,S=Sab,D=Dom",ho.getDias())%></td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora_entrada_desde"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=ho.getHoraEntDesde()%>" />
				</jsp:include>
			</td>

			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora_entrada"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=ho.getHoraEnt()%>" />
				</jsp:include>
			</td>

			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora_entrada_hasta"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=ho.getHoraGraciaEnt()%>" />
				</jsp:include>
			<%System.out.println("ho.getHoraEntHasta()---"+ho.getHoraEntHasta());%>
			</td>

			<td><%=fb.checkbox("verificar_comida"+i,"S",(ho.getVerificarComida().equals("S")?true:false),false)%></td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora_salida_almuerzo"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=ho.getHoraSalAlm()%>" />
				</jsp:include>
			</td>

			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora_entrada_almuerzo"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=ho.getHoraEntAlm()%>" />
				</jsp:include>
			</td>

			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora_salida_desde"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=ho.getHoraSalDesde()%>" />
				</jsp:include>
			</td>

			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora_salida"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=ho.getHoraSal()%>" />
				</jsp:include>
			</td>

			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="<%="hora_salida_hasta"+i%>" />
				<jsp:param name="valueOfTBox1" value="<%=ho.getHoraSalHasta()%>" />
				</jsp:include>
			</td>

			<td><%=fb.intBox("cant_horas"+i,ho.getCantHoras(),false,false,false,2)%></td>
				<td align="center"><%=fb.submit("del"+i,"X",false,false)%></td>
			</tr>
				<%
				}
				%>
				<%=fb.hidden("keySize",""+HorDet.getExcepciones().size())%>
			</table></td></tr></table></td>
		</tr>

		<tr class="TextRow02">
			<td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false)%><%=fb.submit("cancelar","Cancelar",true,false)%> </td>
		</tr>

		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
			<%=fb.formEnd(true)%>
			<!-- ============   F O R M   E N D   H E R E   =========== -->
		</table></td>
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
	String companyId = (String) session.getAttribute("_companyId");
	String del = "0";
	HorDet.getExcepciones().clear();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	for(int i=0;i<keySize;i++){
		if(request.getParameter("del"+i)==null){
			Horario ho = new Horario();
			ho.setCompania(companyId);
			ho.setSecuencia(request.getParameter("secuencia"+i));
			ho.setDescripcion(request.getParameter("descripcion"+i));
			ho.setHoraEnt(request.getParameter("hora_entrada"+i));
			ho.setHoraSal(request.getParameter("hora_salida"+i));
			ho.setDias(request.getParameter("dias"+i));
			ho.setHoraSalAlm(request.getParameter("hora_salida_almuerzo"+i));
			ho.setHoraEntAlm(request.getParameter("hora_entrada_almuerzo"+i));
			ho.setCantHoras(request.getParameter("cant_horas"+i));
			ho.setHoraEntDesde(request.getParameter("hora_entrada_desde"+i));
			ho.setHoraEntHasta(request.getParameter("hora_entrada_hasta"+i));
			ho.setHoraSalDesde(request.getParameter("hora_salida_desde"+i));
			ho.setHoraSalHasta(request.getParameter("hora_salida_hasta"+i));
			if(request.getParameter("verificar_comida"+i)!=null) ho.setVerificarComida("S");
			else ho.setVerificarComida("N");
			HorDet.getExcepciones().add(ho);
		} else {
			del = "1";
		}
	}

	if(request.getParameter("addCmn1")!= null && request.getParameter("action")!=null && request.getParameter("action").equals("add")){
		Horario ho = new Horario();
		ho.setCompania(companyId);
		ho.setHoraEnt("");
		ho.setHoraSal("");
		ho.setDias("");
		ho.setHoraSalAlm("");
		ho.setHoraEntAlm("");
		ho.setCantHoras("");
		ho.setHoraEntDesde("");
		ho.setHoraEntHasta("");
		ho.setHoraSalDesde("");
		ho.setSecuencia("0");
		ho.setHoraSalHasta("");
		ho.setVerificarComida("N");
		HorDet.getExcepciones().add(ho);

		response.sendRedirect("../rhplanilla/reg_excepcion.jsp?mode="+mode+"&change=1");
		return;
	}
	if(del.equals("1")){
		response.sendRedirect("../rhplanilla/reg_excepcion.jsp?mode="+mode+"&change=1");
		return;
	}
	if(request.getParameter("cancelar")!=null && mode.equals("edit")){
		sql = "SELECT secuencia, compania, cod_horario codigo, dia dias, TO_CHAR(hora_entrada,'HH12:MI AM') horaent, TO_CHAR(hora_salida,'HH12:MI AM') horasal, libre, TO_CHAR(hora_salida_almuerzo,'HH12:MI AM') horasalalm, TO_CHAR(hora_entrada_almuerzo,'HH12:MI AM') horaentalm, TO_CHAR(hora_gracia_entrada,'HH12:MI AM') horagraciaent, verificar_comida verificarcomida, TO_CHAR(hora_entrada_desde,'HH12:MI AM') horaentdesde, TO_CHAR(hora_entrada_hasta,'HH12:MI AM') horaenthasta, TO_CHAR(hora_salida_desde,'HH12:MI AM') horasaldesde, TO_CHAR(hora_salida_hasta,'HH12:MI AM') horasalhasta, cant_horas canthoras, horas_com horacomida, minutos_com minutoscomida FROM TBL_PLA_HORARIO_EXCEPCIONES WHERE compania = "+session.getAttribute("_companyId")+" and cod_horario="+HorDet.getCodigo();
		HorDet.setExcepciones(sbb.getBeanList(ConMgr.getConnection(), sql, Horario.class));
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>
