<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="hashCirugia" scope="session" class="java.util.Hashtable" />
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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
ArrayList alViaAd = new ArrayList();
ArrayList alAsa  = new ArrayList();
ArrayList alAnest = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String rowSpan ="2";
String desc = request.getParameter("desc");
if (fg == null) fg = "H";
if (!fg.equalsIgnoreCase("H")) rowSpan = "3";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (desc == null) desc = "";

int rowCount = 0;
String change = request.getParameter("change");
String key = "";
String fecha = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");;
 String desc2="";
if (request.getMethod().equalsIgnoreCase("GET"))
{

alAnest = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_tipo_anestesia order by 2",CommonDataObject.class);
alAsa = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_tipo_asa order by 2",CommonDataObject.class);

if (change == null)
	{
	hashCirugia.clear();

	sql="select tipo_asa, plan, a.codigo, a.cod_paciente, to_char (a.fec_nacimiento, 'dd/mm/yyyy') as fec_nacimiento, a.edad, a.complicacion, a.observacion, a.tipo_registro, a.diagnostico, a.procedimiento, a.tipo_anestesia as tipoanestesia, to_char (a.fecha, 'dd/mm/yyyy') as fecha, a.pac_id, decode (a.tipo_registro, 'H', a.diagnostico, 'C', a.procedimiento) codregistro, c.descripcion as anestesia, decode(a.tipo_registro, 'H', a.desc_diag, 'C', a.desc_proc, nvl(a.desc_diag, a.desc_proc)) descRegistro from tbl_sal_cirugia_paciente a, tbl_sal_tipo_anestesia c where  a.tipo_anestesia = c.codigo(+) and pac_id = "+pacId+" and nvl(admision,"+noAdmision+") = "+noAdmision+" order by codigo";

	al=SQLMgr.getDataList(sql);
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		cdo.setKey(i);
		cdo.setAction("U");
		try
		{
			hashCirugia.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}//End For

	if (al.size() == 0)
		{
			if (!viewMode) modeSec = "add";
			cdo = new CommonDataObject();
			cdo.addColValue("CODIGO","0");
			cdo.addColValue("EDAD","");
			cdo.addColValue("fecha",fecha);
			cdo.addColValue("tipo_registro",fg);
			cdo.setKey(hashCirugia.size()+1);
			cdo.setAction("I");
			try
			{
				hashCirugia.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		else if (!viewMode) modeSec = "edit";

	}//change=null
	else if (!viewMode) modeSec = "edit";
%>
	<!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
		<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
		<!--Para mas Informacion leer (info_v3.txt)-->
		<!--Done by. eduardo.b@issi-panama.com-->
		<!DOCTYPE html>
		<html lang="en">
		<!--comienza el head-->
		<head>
		<meta charset="utf-8">
		<title>Expediente Cellbyte</title>
		<%@ include file="../common/nocache.jsp"%>
		<%@ include file="../common/header_param_bootstrap.jsp"%>
		<jsp:include page="../common/calendar_base.jsp" flush="true">
				<jsp:param name="bootstrap" value="bootstrap"/>
		</jsp:include>
		<script>
		document.title = 'HOSPITALIZACION Y CIRUGIAS - '+document.title;
		var noNewHeight = true;
		function doAction(){}
		function listDiagOrProc(k){
				var tipo = eval('document.form0.tipoRegistro'+k).value;
				if(tipo=='H') abrir_ventana1('../common/search_diagnostico.jsp?fp=HC&index='+k);
				else abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=HC&index='+k);
		}
		function listAnestesia(index){abrir_ventana1('../expediente/list_anestesia.jsp?id=1&index='+index);}
		function imprimirExp(){abrir_ventana('../expediente3.0/print_exp_seccion_4.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}

				$(function(){
						$("#niega").click(function(e){
								if (this.checked) {
										$("#agregar").prop("disabled",true);
										$("button[name*='rem']").prop("disabled",true);
										$("input[name*='fecha']").prop("readOnly",true);
										$("button[name*='resetfecha']").prop("disabled",true);
										$("textarea[name*='observacion']").prop("readOnly",true).val("PACIENTE INDICA NO TIENE ANTECEDENTES");
										$("textarea[name*='complicacion']").prop("readOnly",true).val("");
										$("input[name*='edad']").prop("readOnly",true).val($("#edad", parent.window.document).val());
										$("input[name*='codRegistro']").val("");
										$("input[name*='descRegistro']").val("").prop("disabled",true);
										$("select[name*='tipoRegistro']").prop("disabled",true).val("");
										$("select[name*='tipoanestesia']").prop("disabled",true).val("");
										$("select[name*='tipoanestesia']").prop("disabled",true).val("");
										$("button[name*='btnDiagnostico']").prop("disabled",true);
								} else {
										$("#agregar").prop("disabled",false);
										$("button[name*='rem']").prop("disabled",false);
										$("input[name*='fecha']").prop("readOnly",false);
										$("button[name*='resetfecha']").prop("disabled",false);
										$("textarea[name*='observacion']").prop("readOnly",false).val("");
										$("textarea[name*='complicacion']").prop("readOnly",false);
										$("input[name*='edad']").prop("readOnly",false);
										$("select[name*='tipoRegistro']").prop("disabled",false);
										$("select[name*='tipoanestesia']").prop("disabled",false);
										$("button[name*='btnDiagnostico']").prop("disabled",false)
								}
						});
				});
		</script>
		</head>
		<!--termina el head-->

		<!--comienza el cuerpo del sitio-->
		<body class="body-form">

		<!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->
		<!--INICIO de una fila de elementos-->
		<div class="row">
		<!--INICIO de una fila de elementos-->
		<div class="table-responsive" data-pattern="priority-columns">
				<div class="headerform">
		<!--tabla de boton imprimir-->
		<table cellspacing="0" class="table pull-right table-striped table-custom-1">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("modeSec",modeSec)%>
			<%=fb.hidden("seccion",seccion)%>
			<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
			<%=fb.hidden("dob","")%>
			<%=fb.hidden("codPac","")%>
			<%=fb.hidden("pacId",pacId)%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("hosptSize",""+hashCirugia.size())%>
			<%=fb.hidden("fg",fg)%>
						<%=fb.hidden("desc",desc)%>

		<tr>
		<td><%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimirExp()\"")%></td>
		</tr>
		</table></div>
		<!--fin tabla de boton imprimir-->


		<!--cuerpo del formulario aqui-->
		<!--el class de este sitio siempre debe tener el class="table table-small-font table-bordered table-striped"-->
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<%if(hashCirugia.size() == 1){%>
				<tr>
						<td colspan="6" align="left">
								<label class="pointer"><%=fb.checkbox("niega","S",false,viewMode,"",null,"")%>
								&nbsp;<b>Paciente indica no tiene antecedentes</b>
								</label>
						</td>
				</tr>
				<%}%>

				<tr class="bg-headtabla" >
				<td style="vertical-align: middle !important;">Tipo</td>
				<td style="vertical-align: middle !important;">Diagnostico/Procedimiento</td>
				<!--<td style="vertical-align: middle !important;">Anestesia</td>-->
				<td style="vertical-align: middle !important;">Edad</td>
				<td style="vertical-align: middle !important;">Fecha</td>
				<td style="vertical-align: middle !important;" class="text-center">
						<%=fb.submit("agregar","+",true,viewMode,"btn btn-success btn-sm",null,null)%>
				</td>
				</tr>

				<tbody>
						<!--Comienza una fila de Proceso-->
						<tr class="text-center">


						<%
	al=CmnMgr.reverseRecords(hashCirugia);
	for(int i=0; i<hashCirugia.size();i++)
	{
	key = al.get(i).toString();

	cdo=(CommonDataObject)hashCirugia.get(key);
	String color = "TextRow01";
	String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
	if (i % 2 == 0) color = "TextRow02";
	%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
	<%if(cdo.getAction().equalsIgnoreCase("D")){%>
	 <%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
	<%}else{%>
	<tr class="<%=color%>">
		<td align="center"><%=fb.select("tipoRegistro"+i,"H=Hospitalización, C=Cirugía",cdo.getColValue("TIPO_REGISTRO"),false,viewMode,0,"form-control input-sm",null,null,null,"S")%></td>
		<td class="controls form-inline"><%=fb.textBox("codRegistro"+i,cdo.getColValue("codRegistro"),false,false,true,0,20,"form-control input-sm","width:15%",null)%>
		<%=fb.textBox("descRegistro"+i, cdo.getColValue("descRegistro"),false,false,viewMode,32,200,"form-control input-sm","width:60%",null)%>
				<%=fb.button("btnDiagnostico","...",false,viewMode,"btn btn-inverse btn-sm|fa fa-ellipsis-h fa-printico",null,"onClick=\"javascript:listDiagOrProc("+i+")\"")%>
		</td>
		<!--<td>
			<%=fb.select("tipoanestesia"+i,alAnest,cdo.getColValue("tipoanestesia"),false,viewMode,0,"form-control input-sm",null,null,"","S")%></td>-->
		<td align="center"><%=fb.intBox("edad"+i,cdo.getColValue("edad"),true,false,false,2,3,"form-control input-sm",null,null)%></td>
		<td  align="center" class="controls form-inline"><jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="format" value="dd/mm/yyyy"/>
							<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
							<jsp:param name="readonly" value="n"/>
							</jsp:include>
				</td>
		<td rowspan="<%=rowSpan%>"><%=fb.submit("rem"+i,"x",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:removeItem(this.form.name,"+i+")\"")%></td>
	</tr>
	<tr>
		<td colspan="2" align="left"><cellbytelabel id="6">Observaci&oacute;n</cellbytelabel>:<br>
		<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%>
		</td>
		<td colspan="3"><cellbytelabel id="7">Complicaci&oacute;n</cellbytelabel>:<br>
		<%=fb.textarea("complicacion"+i,cdo.getColValue("complicacion"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
	</tr>
	<%if(!fg.trim().equals("H")){%>
	<tr>
		<td colspan="2" align="left">Tipo Asa<%=fb.select("tipo_asa"+i,alAsa,cdo.getColValue("tipo_asa"),false,viewMode,0,"form-control input-sm",null,null,"","S")%></td>
		<td colspan="3"><cellbytelabel id="8">Plan</cellbytelabel><br>
		<%=fb.textarea("plan"+i,cdo.getColValue("plan"),false,false,viewMode,60,1,1000,"form-control input-sm","width:100%","")%></td>
	</tr>
	<%}%>
	<%}
	}//End For
	fb.appendJsValidation("if(error>0)doAction();");
	%>

					 <!--Termina una fila de Proceso | lo interno de este sector es lo que se tiene que multiplicar-->
				</tbody>
				</table>

		<!--tabla de boton botones guardar cancelar-->
				<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>

		<%=fb.formEnd(true)%>
		</table>
		<!--tabla de boton botones guardar cancelar-->
		</div>
		</div>


		<!-- FIN contenido del sitio aqui-->
		</div>
		<!-- FIN contenido del sitio aqui-->

		<!-- FIN Cuerpo del sitio -->
		</body>
		<!-- FIN Cuerpo del sitio -->


		</html>
		<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	int size = 0;
	if (request.getParameter("hosptSize") != null)
	size = Integer.parseInt(request.getParameter("hosptSize"));

	al.clear();
	hashCirugia.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("TBL_SAL_CIRUGIA_PACIENTE");
		cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision")+" and codigo="+request.getParameter("codigo"+i));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.addColValue("COMPLICACION",request.getParameter("complicacion"+i));

		if (request.getParameter("codigo"+i) ==null || request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals("")){
			cdo.setAutoIncCol("CODIGO");
			cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId"));

			cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("admision",request.getParameter("noAdmision"));
		}
		else {
			cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		}

		if (request.getParameter("tipoRegistro"+i) != null && request.getParameter("tipoRegistro"+i).trim().equals("H")){
			cdo.addColValue("diagnostico",request.getParameter("codRegistro"+i));
		}
		else {
						cdo.addColValue("procedimiento",request.getParameter("codRegistro"+i));
				}

		cdo.addColValue("descRegistro",request.getParameter("descRegistro"+i));
		cdo.addColValue("codRegistro",request.getParameter("codRegistro"+i));

				cdo.addColValue("desc_proc",request.getParameter("descRegistro"+i));
				cdo.addColValue("desc_diag",request.getParameter("descRegistro"+i));

		cdo.addColValue("EDAD",request.getParameter("edad"+i));
		cdo.addColValue("FECHA",request.getParameter("fecha"+i));
		cdo.addColValue("OBSERVACION",request.getParameter("observacion"+i));
		cdo.addColValue("TIPO_REGISTRO",request.getParameter("tipoRegistro"+i));
		cdo.addColValue("TIPO_ANESTESIA",request.getParameter("tipoanestesia"+i));
		cdo.addColValue("tipoanestesia",request.getParameter("tipoanestesia"+i));

		if(!fg.trim().equals("H")){
			cdo.addColValue("tipo_asa",request.getParameter("tipo_asa"+i));
			cdo.addColValue("plan",request.getParameter("plan"+i));
		}

			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getColValue("key");
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}
			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					hashCirugia.put(cdo.getKey(),cdo);
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
	}//for

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&fg="+request.getParameter("fg")+"&desc="+desc);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();
		cdo.addColValue("CODIGO","0");
		cdo.addColValue("fecha",fecha);
		cdo.addColValue("TIPO_ANESTESIA","");
		cdo.addColValue("PROCEDIMIENTO","");
		cdo.addColValue("tipo_registro",fg);

		cdo.setKey(hashCirugia.size()+1);
		cdo.setAction("I");
		try
		{
			hashCirugia.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&fg="+request.getParameter("fg")+"&desc="+desc);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_cirugia_paciente");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId"));
			cdo.setAction("I");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>