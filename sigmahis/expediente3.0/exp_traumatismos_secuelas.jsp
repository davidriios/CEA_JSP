<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="hashTraum" scope="session" class="java.util.Hashtable" />
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
ArrayList alTraum = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDateTime2 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String key = "";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;
String change = request.getParameter("change");
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
		alTraum = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_factor_trauma order by codigo",CommonDataObject.class);
	if (change == null)
	{
	hashTraum.clear();
	sql="select a.cod_paciente, to_char(a.fec_nacimiento,'dd/mm/yyyy') as fec_nacimiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy hh12:mi am') as fecha, a.tipo_trauma, a.observacion, a.pac_id,a.usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion from tbl_sal_antecedente_trauma a where a.pac_id="+pacId+" order by a.fecha desc";
	al=SQLMgr.getDataList(sql);
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		cdo.setAction("U");
		cdo.setKey(i);
		try
		{
			hashTraum.put(cdo.getKey(), cdo);
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
			//cdo.addColValue("fec_nacimiento",cDateTime.subString(0,10));
			cdo.addColValue("fecha",cDateTime2);
			cdo.setKey(hashTraum.size()+1);
			cdo.setAction("I");
			try
			{
				hashTraum.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		else if (!viewMode) modeSec = "edit";

	}//change=null

%>
	 <!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
		<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
		<!--Para mas Informacion leer (info_v3.txt)-->
		<!--Done by. eduardo.b@issi-panama.com-->
		<!DOCTYPE html>
		<html lang="en">
		<!--comienza el head-->
		<head>
		<%@ include file="../common/nocache.jsp"%>
		<%@ include file="../common/header_param_bootstrap.jsp"%>
		<jsp:include page="../common/calendar_base.jsp" flush="true">
				<jsp:param name="bootstrap" value="bootstrap"/>
		</jsp:include>
		<script>
		function imprimir(){abrir_ventana('../expediente3.0/print_exp_seccion_6.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}

		$(function(){
				$("#niega").click(function(e){
						if (this.checked) {
								$("#agregar").prop("disabled",true);
								$("button:submit[name*='rem']").prop("disabled",true);
								$("input[name*='fecha']").prop("readOnly",true);
								$("button[name*='resetfecha']").prop("disabled",true);
								$("select[name*='tipoTrauma']").prop("disabled",true).val(4);
						} else {
								$("#agregar").prop("disabled",false);
								$("button:submit[name*='rem']").prop("disabled",false);
								$("input[name*='fecha']").prop("readOnly",false);
								$("button[name*='resetfecha']").prop("disabled",false);
								$("select[name*='tipoTrauma']").prop("disabled",false).val("");
						}
				});

				$("select[name*='tipoTrauma'] option, select[name*='_tipoTrauma'] option").each(function(){
						if (this.selected && this.value == 4){
								$("#niega, #_niegaDsp").prop("checked", true)
						}
				});
		});

		function canSubmit() {
				var proceed = true;
				var niegas = [];
				$("select[name*='tipoTrauma'] option").each(function(){
						if (this.selected && !this.value) {
								proceed = false;
								parent.CBMSG.error("Por favor seleccionar el Diagnóstico/Procedimiento!");
								return false;
						}
				});

				if (proceed){
						if (!$("#niega").is(":checked")) {
								$("select[name*='tipoTrauma'] option").each(function(){
										if (this.selected && this.value == 4) {
												proceed = false;
												parent.CBMSG.error("No puedes seleccionar 'NIEGA' sin haber marcado el check 'Paciente indica no tiene antecedentes'");
												return false;
										}
								});
						} else {
								$("select[name*='tipoTrauma'] option").each(function(){
										if (this.selected && this.value != 4) {
												proceed = false;
												parent.CBMSG.error("Por favor quitar el check: 'Paciente indica no tiene antecedentes'");
												return false;
										}
								});
						}
				}
				return proceed;
		}
		</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
		</head>
		<!--termina el head-->

		<!--comienza el cuerpo del sitio-->
		<body class="body-form">

		<!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->
		<!--INICIO de una fila de elementos-->
		<div class="row">
		<!--INICIO de una fila de elementos-->
		<div class="table-responsive" data-pattern="priority-columns">
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
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("traumaSize",""+hashTraum.size())%>
		<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
				<div class="headerform">
		<!--tabla de boton imprimir-->
		<table cellspacing="0" class="table pull-right table-striped table-custom-1">
		<tr>
		<td><%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimir('')\"")%></td>
		</tr>
		</table></div>
		<!--fin tabla de boton imprimir-->


		<!--cuerpo del formulario aqui-->
		<!--el class de este sitio siempre debe tener el class="table table-small-font table-bordered table-striped"-->
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<%if(hashTraum.size() == 1){%>
				<tr>
						<td colspan="3" align="left">
								<label class="pointer"><%=fb.checkbox("niega","S",false,viewMode,"",null,"")%>
								&nbsp;<b>Paciente indica no tiene antecedentes</b>
								</label>
						</td>
				</tr>
				<%}%>

				<tr class="bg-headtabla" >
				<td style="vertical-align: middle !important;">Tipo</td>
				<td style="vertical-align: middle !important;">Diagnostico/Procedimiento</td>
				<td style="vertical-align: middle !important;" class="text-center">
					<%=fb.submit("agregar","+",true,viewMode,"btn btn-success btn-sm",null,null)%>
				</td>
				</tr>

				<tbody>
						<%
					al = CmnMgr.reverseRecords(hashTraum);

					for (int i=0; i<hashTraum.size(); i++)
					{
					key = al.get(i).toString();
					cdo = (CommonDataObject) hashTraum.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
			<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
			<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
			<%if(cdo.getAction().equalsIgnoreCase("D")){%>
			<%=fb.hidden("tipoTrauma"+i,cdo.getColValue("tipo_trauma"))%>
			<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
			<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
			<%}else{%>
		<tr>
			<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
										<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
								</jsp:include>
						</td>
			<td><%=fb.select("tipoTrauma"+i,alTraum,cdo.getColValue("tipo_trauma"),false,viewMode,0,"form-control input-sm",null,null,null,"S")%></td>
			<td align="center">
				<%=fb.submit("rem"+i,"x",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:removeItem(this.form.name,"+i+")\"")%>
						</td>
		</tr>
		<tr class="<%=color%>" >
			<td colspan="3"> <strong>Observaciones:</strong>&nbsp;<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,60,1,2000,"form-control input-md","width:100%","")%></td>
		</tr>
		<%}%>

<%
}
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

		</table>  </div>
		<!--tabla de boton botones guardar cancelar-->

		<%=fb.formEnd(true)%>
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
	if (request.getParameter("traumaSize") != null)
	size = Integer.parseInt(request.getParameter("traumaSize"));
	al.clear();
	hashTraum.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_antecedente_trauma");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and codigo="+request.getParameter("codigo"+i));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("FECHA",request.getParameter("fecha"+i));

				if(request.getParameter("niega") != null) {
						cdo.addColValue("TIPO_TRAUMA", "4");
				} else {
						cdo.addColValue("TIPO_TRAUMA",request.getParameter("tipoTrauma"+i));
				}

		if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals("")){
			cdo.setAutoIncCol("CODIGO");
			cdo.setAutoIncWhereClause("pac_id = "+request.getParameter("pacId"));

			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("admision",request.getParameter("noAdmision"));
		} else {
			cdo.addColValue("CODIGO",request.getParameter("codigo"+i));
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		}
		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			itemRemoved = cdo.getKey();
			if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
			else cdo.setAction("D");
		}
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				al.add(cdo);
				hashTraum.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
	}//for
	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+noAdmision+"&seccion="+request.getParameter("seccion")+"&desc="+desc);
		return;
	}

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();
		cdo.addColValue("CODIGO","0");
		cdo.addColValue("FECHA",cDateTime2);
		cdo.setAction("I");
		cdo.setKey(hashTraum.size() + 1);
		try
		{
			hashTraum.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+noAdmision+"&seccion="+request.getParameter("seccion")+"&desc="+desc);
		return;
	}

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_antecedente_trauma");
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
