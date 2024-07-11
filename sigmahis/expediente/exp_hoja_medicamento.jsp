<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.expediente.HojaMedicamento"%>
<%@ page import="issi.expediente.HojaMedicamentoDet"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="HashMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMed" scope="session" class="java.util.Vector" />
<jsp:useBean id="HMMgr" scope="page" class="issi.expediente.HojaMedicamentoMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
SAL310111 Expediente Enfermeria
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
HMMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
HojaMedicamento hm = new HojaMedicamento();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha = request.getParameter("fecha");
String hora = request.getParameter("hora");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");

int lastLineNo = 0;
String key = "";

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
/*
fecha ="17/11/2009";
hora = "09:24 am";
mode ="edit";*/
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
  HashMed.clear();
  vMed.clear();
/*sql=" select a.cod_paciente codPaciente, to_char(a.fec_nacimiento,'dd/mm/yyyy') fecNacimiento, a.secuencia, to_char(a.fecha,'dd/mm/yyyy') fecha,to_char(a.hora,'hh12:mi am') hora, a.emp_provincia empProvincia, a.emp_sigla empSigla, a.emp_tomo empTomo, a.emp_asiento empasiento, a.emp_compania empCompania, a.tipo_personal tipoPersonal, a.personal_g personalG, a.emp_id empId from  sal_medicamento_admision a where a.pac_id = "+pacId+"and a.secuencia = "+noAdmision+" order by to_date(a.fecha,'dd/mm/yyyy') , to_date(to_char(a.hora,'hh12:mi AM'),'hh12:mi am') asc ";

	al2 = SQLMgr.getDataList(sql);*/

	if (modeSec.equalsIgnoreCase("add"))
	{
		String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
		hm.setFecha(cDate.substring(0,10));
		hm.setHora(cDate.substring(11));

		/*HojaMedicamentoDet det = new HojaMedicamentoDet();
		det.setCodigo("0");
		//det.setFecha(cDate.substring(0,10));
		det.setHora(cDate.substring(11));

		lastLineNo++;
		if (lastLineNo < 10) key = "00" + lastLineNo;
		else if (lastLineNo < 100) key = "0" + lastLineNo;
		else key = "" + lastLineNo;
		det.setKey(""+lastLineNo);

		try
		{
			HashMed.put(key, det);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}*/
	}
	else
	{
		if (fecha == null || hora == null) throw new Exception("La Fecha y Hora no son válidas. Por favor intente nuevamente!");
		hm.setFecha(fecha);
		hm.setHora(hora);


		sql=" select a.cod_paciente codPaciente, to_char(a.fec_nacimiento,'dd/mm/yyyy') fecNacimiento, a.secuencia, to_char(a.fecha,'dd/mm/yyyy') fecha,to_char(a.hora,'hh12:mi am') hora, a.emp_provincia empProvincia, a.emp_sigla empSigla, a.emp_tomo empTomo, a.emp_asiento empasiento, a.emp_compania empCompania, a.tipo_personal tipoPersonal, a.personal_g personalG, a.emp_id empId from  tbl_sal_medicamento_admision a where a.pac_id = "+pacId+"and a.secuencia = "+noAdmision+"  and to_char(a.fecha,'dd/mm/yyyy')='"+fecha+"' and to_date(to_char(a.hora,'hh12:mi am'),'hh12:mi am')=to_date('"+hora+"','hh12:mi am') ";

		 hm = (HojaMedicamento) sbb.getSingleRowBean(ConMgr.getConnection(), sql, HojaMedicamento.class);
		 //System.out.println("Sql :: == "+sql);


		sql = " select  a.codigo, to_char(a.hora,'hh12:mi am') hora ,medicamento,a.dosis, a.via,a.frecuencia,a.observacion, dosis_desc || '@' || (select '<b>ACCION:</b> '|| m.accion||'<br><b>INTERACCION:</b>'||m.interaccion from tbl_sal_medicamentos m where m.compania = "+((String) session.getAttribute("_companyId"))+" and m.status = 'A' and antibio_ctrl = 'S' and m.medicamento = substr(a.medicamento,0, instr(a.medicamento,'/')-2 ) and rownum = 1) dosisDesc,a.cantidad from tbl_sal_detalle_medicamento a where a.pac_id = "+pacId+"and a.secuencia = "+noAdmision+"  and to_date(to_char(a.fecha_medica,'dd/mm/yyyy'),'dd/mm/yyyy')= to_date('"+fecha+"','dd/mm/yyyy') and to_date(to_char(a.hora_medica,'hh12:mi am'),'hh12:mi am')=to_date('"+hora+"','hh12:mi am') order by a.codigo";

		al = sbb.getBeanList(ConMgr.getConnection(),sql,HojaMedicamentoDet.class);
		//System.out.println("SqlDet :: == "+sql);

		lastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			HojaMedicamentoDet det = (HojaMedicamentoDet) al.get(i - 1);

			if (i < 10) key = "00"+i;
			else if (i < 100) key = "0"+i;
			else key = ""+i;
			det.setKey(key);

			try
			{
				HashMed.put(key, det);
				vMed.add(det.getMedicamento());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Hoja de medicamento - '+document.title;
function doAction(){newHeight();}
function imprimirMedicamento(){abrir_ventana1('../expediente/print_hoja_medicamento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function viewMedicamento(k){abrir_ventana1('../expediente/hoja_medicamento_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function add(){window.location = '../expediente/exp_hoja_medicamento.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>';}
function verActivos(){abrir_ventana1('../expediente/exp_orden_medicamentos_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=A');}
function verOmitidos(){abrir_ventana1('../expediente/exp_orden_medicamentos_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=O');}
function doSubmit(formName,bAction){parent.setPatientInfo(formName,'iDetalle');setBAction(formName,bAction);window.frames['iDetalle'].doSubmit();}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("cds",""+cds)%>

<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
		<tr class="TextRow02">
			<td colspan="4" align="right">
			<a href="javascript:verActivos()" class="Link00">[ <cellbytelabel id="1">Ver Medic. Activos</cellbytelabel> ]</a>
			<a href="javascript:verOmitidos()" class="Link00">[ <cellbytelabel id="2">Ver Medic. Omitidos</cellbytelabel> ]</a>
			<%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="3">Agregar</cellbytelabel> ]</a><%}%>
			<a href="javascript:viewMedicamento()" class="Link00">[ <cellbytelabel id="4">Consultar</cellbytelabel> ]</a>
			<a href="javascript:imprimirMedicamento()" class="Link00">[ <cellbytelabel id="5">Imprimir</cellbytelabel> ]</a>
			</td>
		</tr>
		<!---<tr>
					<td  colspan="4">
					<div id="listado" width="100%" style="overflow:scroll;position:relative;height:100">
					<div id="detListado" width="98%" style="overflow;position:absolute">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td colspan="2">&nbsp;Listado de Medicamentos</td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="20%">Fecha</td>
							<td width="80%">Hora</td>
						</tr>
<%
for (int i=1; i<=al2.size(); i++)
{
	cdo = (CommonDataObject) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("fechaMed"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("horaMed"+i,cdo.getColValue("hora"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:viewMedicamento(<%=i%>)" style="text-decoration:none; cursor:pointer">
				<td><%=cdo.getColValue("fecha")%></td>
				<td><%=cdo.getColValue("hora")%></td>
		</tr>
<%
}
%>
						</table>
					</div>
					</div>
					</td>
				</tr>


		---->



		<tr class="TextRow01">
			<td width="25%" align="right"><cellbytelabel id="6">Fecha</cellbytelabel></td>
			<td width="25%"><%//=fb.textBox("fecha",hm.getFecha(),true,false,true,10)%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=hm.getFecha()%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include>

			</td>
			<td width="25%" align="right"><cellbytelabel id="7">Hora</cellbytelabel></td>
			<td width="25%"><%//=fb.textBox("hora",hm.getHora(),true,false,true,11)%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="format" value="hh12:mi am" />
				<jsp:param name="nameOfTBox1" value="hora" />
				<jsp:param name="valueOfTBox1" value="<%=hm.getHora()%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include>


			</td>
		</tr>

		<tr>
			<td colspan="4"><iframe name="iDetalle" id="iDetalle" width="100%" height="0" scrolling="no" frameborder="0" src="../expediente/exp_hoja_medicamento_det.jsp?seccion=<%=seccion%>&mode=<%=mode%>&modeSec=<%=modeSec%>&cds=<%=cds%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&lastLineNo=<%=lastLineNo%>"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel id="8">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="9">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="10">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="11">Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	HMMgr.setErrCode(request.getParameter("errCode"));
	HMMgr.setErrMsg(request.getParameter("errMsg"));
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (HMMgr.getErrCode().equals("1"))
{
%>
	alert('<%=HMMgr.getErrMsg()%>');
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
	parent.parent.doRedirect(0);
<%
	}
} else throw new Exception(HMMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&lastLineNo=<%=lastLineNo%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&lastLineNo=<%=lastLineNo%>&fecha=<%=request.getParameter("fecha")%>&hora=<%=request.getParameter("hora")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>

