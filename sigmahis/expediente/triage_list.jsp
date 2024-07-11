<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SPMgr" scope="page" class="issi.expediente.SignoPacienteMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SPMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alDet = new ArrayList();
Hashtable det = new Hashtable();

boolean viewMode = false;
String sql = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String seccion = request.getParameter("seccion");
String exp = request.getParameter("exp");

if (exp == null) exp = "";

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select a.tipo_persona as tipoPersona, nvl(a.observacion,' ') as observacion, nvl(a.accion,' ') as accion, decode(a.categoria,'1','I','2','II','3','III',a.categoria) as categoria, decode(a.evacuacion,'S','[ X ]','[__]') as evacuacion, decode(a.miccion,'S','[ X ]','[__]') as miccion, decode(a.vomito,'S','[ X ]','[__]') as vomito, nvl(a.miccion_obs,' ') as miccionObs, nvl(a.vomito_obs,' ') as vomitoObs, nvl(a.evacuacion_obs,' ') as evacuacionObs , to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro, to_char(a.hora_registro,'hh12:mi:ss am') as horaRegistro, a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif,decode(a.dolor,'S','SI','N','NO',' ') as dolor,nvl(a.escala,' ')escala , decode(a.preocupacion,'S', '[ X ]','[__]') preocupacion, nvl(preocupacion_obs,' ') preocupacionObs, nivel_conciencia nivelConciencia, dificultad_resp dificultadResp, loquios, proteinuria, liq_amnio liqAmnio, nvl(padecimiento_actual,' ') as padecimientoActual, decode(a.status,'I','INVALIDO','VALIDO') as status from tbl_sal_signo_paciente a where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision;

	if (exp.trim().equals("")) {
		sql += " and a.tipo_persona <> 'T' ";
	}

	sql += " order by a.fecha_registro desc, a.hora_registro desc";

	//System.out.println("sql = "+sql);
	al = sbb.getBeanList(ConMgr.getConnection(), sql, SignoPaciente.class);

	System.out.println("---------------------------------------------------------------------------------------");
	System.out.println(sql);
	System.out.println("---------------------------------------------------------------------------------------");


	for (int i=0; i<al.size(); i++)
	{
		SignoPaciente sp = (SignoPaciente) al.get(i);

		sql = "select a.signo_vital as signoVital, a.tipo_persona as tipoPersona, nvl(a.resultado,' ') resultado, b.descripcion as signoDesc, nvl(c.sigla_um,' ') as signoUnit from tbl_sal_detalle_signo a, tbl_sal_signo_vital b, tbl_sal_signo_vital_um c where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.signo_vital=b.codigo and a.signo_vital=c.cod_signo(+) and c.valor_default(+)='S' and a.tipo_persona = '"+sp.getTipoPersona()+"' and to_date(to_char(a.fecha_signo,'dd/mm/yyyy'),'dd/mm/yyyy')  =  to_date('"+sp.getFecha()+"','dd/mm/yyyy') and to_date(to_char(a.hora,'dd/mm/yyyy hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') =  to_date('"+sp.getFecha()+" "+sp.getHora()+"','dd/mm/yyyy hh12:mi:ss am') order by b.orden, a.fecha_signo, a.hora, a.signo_vital";//depends on header's status

	System.out.println("---------------------------------------------------------------------------------------");
	System.out.println(sql);
	System.out.println("---------------------------------------------------------------------------------------");

	alDet = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleSignoPaciente.class);


		for (int j=0; j<alDet.size(); j++)
		{
			DetalleSignoPaciente spd = (DetalleSignoPaciente) alDet.get(j);
			if (sp.getTipoPersona().equals(spd.getTipoPersona())) sp.addDetalleSignoPaciente(spd);
		}
		al.set(i,sp);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Triage - '+document.title;

function doAction()
{
}
function printExp(opt){
	abrir_ventana("../expediente/print_exp_seccion_77.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&exp=<%=exp%>&opt="+opt);
}
function invalidate(idx){
	var tipoPersona=eval('document.form0.tipoPersona'+idx).value;
	var fecha=eval('document.form0.fecha'+idx).value;
	var hora=eval('document.form0.hora'+idx).value;
	showPopWin('../process/exp_invalidate_vs.jsp?pacId=<%=pacId%>&admision=<%=noAdmision%>&tipoPersona='+tipoPersona+'&fecha='+fecha+'&hora='+hora,winWidth*.75,winHeight*.65,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TRIAGE/SIGNOS VITALES"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
<%fb = new FormBean("formTop",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
	<td colspan="4" align="right">
		<%=fb.button("print_top_all","Imprimir Todos",true,false,null,null,"onClick=\"javascript:printExp('all')\"")%>
		<%=fb.button("print_top","Imprimir",true,false,null,null,"onClick=\"javascript:printExp('')\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="0" cellspacing="0" class="TableBorderLightGray">

		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
										<jsp:param name="desc" value="<%=desc%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%
String tipoPersona = "";
for (int i=0; i<al.size(); i++)
{
	SignoPaciente sp = (SignoPaciente) al.get(i);
	if (sp.getTipoPersona().equalsIgnoreCase("T")) tipoPersona = "TRIAGE";
	else if (sp.getTipoPersona().equalsIgnoreCase("M")) tipoPersona = "MEDICO";
	else if (sp.getTipoPersona().equalsIgnoreCase("E")) tipoPersona = "ENFERMERA";
	else if (sp.getTipoPersona().equalsIgnoreCase("A")) tipoPersona = "AUXILIAR";
	else tipoPersona = 	sp.getTipoPersona();

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("tipoPersona"+i,sp.getTipoPersona())%>
<%=fb.hidden("fecha"+i,sp.getFecha())%>
<%=fb.hidden("hora"+i,sp.getHora())%>
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<tr class="<%=color%>">
			<td colspan="4" align="right">
				<% if (sp.getStatus().equalsIgnoreCase("VALIDO")) { %>
					<authtype type='50'><%=fb.button("btnInvalidate","I N V A L I D A R",false,false,null,null,"onClick=\"javascript:invalidate("+i+")\"")%></authtype>
				<% } else { %>
					<span class="RedTextBold"><%=sp.getStatus()%></span>
				<% } %>
			</td>
		</tr>
		<tr class="<%=color%>">
			<td width="15%" align="right"><cellbytelabel id="1">Fecha/Hora Toma</cellbytelabel> :</td>
			<td width="35%"><%=sp.getFechaRegistro()%> <%=sp.getHoraRegistro()%></td>
			<td width="15%" align="right"><cellbytelabel id="2">Registrado Por</cellbytelabel> :</td>
			<td width="35%"><%=tipoPersona%>&nbsp;-<%=sp.getUsuarioCreacion()%>&nbsp;&nbsp;&nbsp;- <cellbytelabel id="3">Fecha</cellbytelabel>: <%=sp.getFechaCreacion()%></td>
		</tr>
		<tr class="<%=color%>">
				<td align="right"><cellbytelabel id="4">Evacuaci&oacute;n</cellbytelabel></td>
				<td colspan="3"><%=sp.getEvacuacion()%>
				&nbsp;&nbsp;&nbsp;<cellbytelabel id="5">Observaci&oacute;n</cellbytelabel>: &nbsp;&nbsp;&nbsp<%=sp.getEvacuacionObs()%></td>
		</tr>
		<tr class="<%=color%>">
				<td align="right"><cellbytelabel id="6">Micci&oacute;n</cellbytelabel></td>
				<td colspan="3"><%=sp.getMiccion()%>
				&nbsp;&nbsp;&nbsp;<cellbytelabel id="5">Observaci&oacute;n</cellbytelabel>: &nbsp;&nbsp;&nbsp <%=sp.getMiccionObs()%></td>
		</tr>

				<%if(exp.trim().equals("3")){%>
		<tr class="<%=color%>">
				<td align="right"><cellbytelabel id="6">Existe preocupación (doctor, enfermera, familiares)</cellbytelabel></td>
				<td colspan="3"><%=sp.getPreocupacion()%>
				&nbsp;&nbsp;&nbsp;<cellbytelabel id="5">Observaci&oacute;n</cellbytelabel>: &nbsp;&nbsp;&nbsp <%=sp.getPreocupacionObs()%></td>
		</tr>
				<%}%>

		<tr class="<%=color%>">
				<td align="right"><cellbytelabel id="6">V&oacute;mito</cellbytelabel></td>
				<td colspan="3"><%=sp.getVomito()%>
				&nbsp;&nbsp;&nbsp;<cellbytelabel id="5">Observaci&oacute;n</cellbytelabel>: &nbsp;&nbsp;&nbsp <%=sp.getVomitoObs()%></td>
		</tr>
		<tr class="<%=color%>">
				<td align="right"><cellbytelabel id="7">Dolor</cellbytelabel></td>
				<td colspan="3"><%=sp.getDolor()%>
				&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel id="8">Valor</cellbytelabel>&nbsp;&nbsp <%=sp.getEscala()%></td>
		</tr>
				<%if(exp.equals("3")){%>
				<tr class="<%=color%>">
						<td align="right"><cellbytelabel>Nivel de conciencia</cellbytelabel>:</td>
			<td colspan="3">
								<label class="pointer"><%=fb.radio("nivel_conciencia","0",(sp.getNivelConciencia() != null && sp.getNivelConciencia().equals("0") ),true,false,null,null,"")%>&nbsp;Normal</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("nivel_conciencia","1",(sp.getNivelConciencia() != null && sp.getNivelConciencia().equals("1") ),true,false,null,null,"")%>&nbsp;Disminuido</label>
						</td>
		</tr>

				<tr class="<%=color%>">
						<td align="right"><cellbytelabel>Dificultad respiratoria</cellbytelabel>:</td>
			<td colspan="3">
								<label class="pointer"><%=fb.radio("dificultad_resp","1",(sp.getDificultadResp() != null && sp.getDificultadResp().equals("1") ),true,false,null,null,"")%>&nbsp;Severa/Moderada</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("dificultad_resp","0",(sp.getDificultadResp() != null && sp.getDificultadResp().equals("0") ),true,false,null,null,"")%>&nbsp;Leve/Ninguna</label>
						</td>
		</tr>

				<tr class="<%=color%>">
						<td align="right"><cellbytelabel>Loquios</cellbytelabel>:</td>
			<td colspan="3">
								<label class="pointer"><%=fb.radio("loquios","0",(sp.getLoquios() != null && sp.getLoquios().equals("0") ),true,false,null,null,"")%>&nbsp;Normal</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("loquios","3",(sp.getLoquios() != null && sp.getLoquios().equals("3") ),true,false,null,null,"")%>&nbsp;Aumentado / Falta</label>
						</td>
		</tr>

				<tr class="<%=color%>">
						<td align="right"><cellbytelabel>Proteinuria</cellbytelabel>:</td>
			<td colspan="3">
								<%=fb.textBox("proteinuria", sp.getProteinuria(), false, false, true, 4,2,"form-control form-inline input-sm",null,null,null,false, "")%>
						</td>
		</tr>

				<tr class="<%=color%>">
						<td align="right"><cellbytelabel>L&iacute;quido amni&oacute;tico</cellbytelabel>:</td>
			<td colspan="3">
								<label class="pointer"><%=fb.radio("liq_amnio","0",(sp.getLiqAmnio() != null && sp.getLiqAmnio().equals("0") ),true,false,null,null,"")%>&nbsp;Claro / Rosa</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("liq_amnio","3",(sp.getLiqAmnio() != null && sp.getLiqAmnio().equals("3") ),true,false,null,null,"")%>&nbsp;Verde</label>
						</td>
		</tr>
				<%}%>

		<tr class="<%=color%>">
			<td align="right"><cellbytelabel id="5">Observaci&oacute;n</cellbytelabel></td>
			<td><%=sp.getObservacion()%></td>
			<td align="right"><cellbytelabel id="9">Acci&oacute;n</cellbytelabel></td>
			<td><%=sp.getAccion()%></td>
		</tr>

		<tr class="<%=color%>">
			<td align="right"><cellbytelabel id="5">Padecimiento Actual</cellbytelabel></td>
			<td colspan="3"><%=sp.getPadecimientoActual()%></td>
		</tr>

		<tr>
			<td colspan="4" class="TableBorder">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr align="center" class="TextHeader">
					<td width="35%"><cellbytelabel id="10">Signo Vital</cellbytelabel></td>
					<td width="10%"><cellbytelabel id="8">Valor</cellbytelabel></td>
					<td width="5%">&nbsp;</td>
					<td width="35%"><cellbytelabel>
						<%//=(alDet.size() > 1)?"Signo Vital":"&nbsp;"%>
						<%if(alDet.size() > 1){%> Signo Vital <%}else{%> &nbsp;<%}%>
					</cellbytelabel></td>
					<td width="10%">
						<cellbytelabel id="8">
							<%//=(alDet.size() > 1)?"Valor":"&nbsp;"%>
							<%if(alDet.size() > 1){%> Valor <%}else{%> &nbsp;<%}%>
						</cellbytelabel></td>
					<td width="5%">&nbsp;</td>
				</tr>
<%
	int lc = 0;
	int ic = 0;
	for (int j=0; j<sp.getDetalleSignoPaciente().size(); j++)
	{
		DetalleSignoPaciente spd = sp.getDetalleSignoPaciente(j);

		if (ic == 0)
		{
%>
				<tr class="<%=color%>">
<%
		} //end if
		ic++;
%>
				<td><%=spd.getSignoDesc()%></td> <!--signos vitales descripcion-->
					<td align="right"><%=spd.getResultado()%></td><!--Valores-->
					<td><%=spd.getSignoUnit()%></td>
<%
		if (ic == 2 || (j + 1) == sp.getDetalleSignoPaciente().size())
		{
			if (ic != 2 && (j + 1) == sp.getDetalleSignoPaciente().size())
			{
%>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
<%
			}//end if
			ic = 0;
			lc++;
%>
				</tr>
<%
		}//end if
	} //end for
%>
				</table>
			</td>
		</tr>
		</table>
<%
}
if (al.size() == 0)
{
%>
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<tr class="TextRow01">
			<td colspan="4" align="center"><cellbytelabel id="11">No hay datos de Triage</cellbytelabel>!</td>
		</tr>
		</table>
<%
}
%>
<%=fb.formEnd(true)%>
	</td>
</tr>
<%fb = new FormBean("formBottom",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<tr>
	<td colspan="4" align="right">
		<%=fb.button("print_bottom_all","Imprimir Todos",true,false,null,null,"onClick=\"javascript:printExp('all')\"")%>
		<%=fb.button("print_bottom","Imprimir",true,false,null,null,"onClick=\"javascript:printExp('')\"")%>
		&nbsp;&nbsp;&nbsp;<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
%>
