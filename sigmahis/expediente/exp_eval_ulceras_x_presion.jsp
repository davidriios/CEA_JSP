<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.UlceraPresion"%>
<%@ page import="issi.expediente.DetalleUlceras"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ULCERMgr" scope="session" class="issi.expediente.UlcerasPresionMgr" />
<jsp:useBean id="iHashEval" scope="session" class="java.util.Hashtable" />
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
ULCERMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
UlceraPresion ulcera = new UlceraPresion();

boolean viewMode = false;
String sql ="";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String fecha_eval = request.getParameter("fecha_eval");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String filter = "",appendFilter ="", op ="";
String key = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
iHashEval.clear();
sql="select to_char(fecha,'dd/mm/yyyy') as fecha, observacion from tbl_sal_ulcera_presion where pac_id="+pacId+" and secuencia="+noAdmision+" order by to_date(fecha,'dd/mm/yyyy') desc";
al2 = SQLMgr.getDataList(sql); 
			for (int i=1; i<=al2.size(); i++)
			{
						cdo = (CommonDataObject) al2.get(i-1);
						cdo.setKey(i-1);
						
						if(cdo.getColValue("fecha").equals(cDateTime.substring(0,10)))
						{
						cdo.addColValue("OBSERVACION","Evaluacion actual ");
							op = "0";
						}else
						{cdo.addColValue("OBSERVACION","Evaluacion "+ (1+al2.size() - i));
								appendFilter = "1";
						}
						try
						{
							iHashEval.put(cdo.getKey(), cdo);
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
			}//for

			if(al2.size() == 0)
			{
					if (!viewMode) modeSec = "add";
					cdo = new CommonDataObject();
					cdo.addColValue("FECHA",cDateTime.substring(0,10));
					cdo.addColValue("OBSERVACION","Evaluacion Actual");
					cdo.setKey(iHashEval.size() +1);

					try
					{
						iHashEval.put(cdo.getKey(), cdo);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}


			}


if(fecha_eval != null){ filter = fecha_eval;
if(fecha_eval.trim().equals(cDateTime.substring(0,10))){modeSec="edit";if(!viewMode)viewMode= false;}
}
else filter = cDateTime.substring(0,10);


sql="select to_char(fecha,'dd/mm/yyyy') as fecha, observacion, usuario_creacion as usuarioCreacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, usuario_modificacion as usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fechaModificacion from tbl_sal_ulcera_presion where pac_id="+pacId+" and secuencia="+noAdmision+" and to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy')= to_date('"+filter+"','dd/mm/yyyy')";
ulcera = (UlceraPresion) sbb.getSingleRowBean(ConMgr.getConnection(), sql, UlceraPresion.class);
if(ulcera == null)
{
			ulcera = new UlceraPresion();
			ulcera.setFecha(cDateTime.substring(0,10));
			ulcera.setUsuarioCreacion(UserDet.getUserName());
			ulcera.setFechaCreacion(cDateTime);
			ulcera.setUsuarioModificacion(UserDet.getUserName());
			ulcera.setFechaModificacion(cDateTime);
			if (!viewMode) modeSec = "add";
}
else if (!viewMode) modeSec = "edit";

if(fecha_eval != null)
filter = fecha_eval;
else
filter = cDateTime.substring(0,10);
	sql = "select a.codigo as codigo, a.descripcion as descripcion, b.observacion as observacion , nvl(b.seleccionar,'N') as seleccionar, to_char(b.fecha_up,'dd/mm/yyyy') as fechaUp, b.cod_concepto as codConcepto  from TBL_SAL_CONCEPTO_ULCERA a, TBL_SAL_DET_ULCERA_PRESION b where a.codigo=b.cod_concepto(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" and to_date(to_char(fecha_up(+),'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy') ORDER BY a.codigo";
	al = SQLMgr.getDataList(sql);
	if (al.size() == 0)
		 if (!viewMode) modeSec = "add";
	else if (!viewMode) modeSec = "edit";

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Evaluacion de Ulceras por Presión - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){setHeight();checkViewMode();}
function setHeight(){newHeight();}
function setEvaluacion(k){var fecha_e = eval('document.form0.fecha_evaluacion'+k).value ;window.location= '../expediente/exp_eval_ulceras_x_presion.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval='+fecha_e+'&desc=<%=desc%>';}
function isChecked(k){eval('document.form0.observacion2'+k).disabled = !eval('document.form0.aplicar'+k).checked;if (eval('document.form0.aplicar'+k).checked){eval('document.form0.observacion2'+k).className = 'FormDataObjectEnabled';}else{eval('document.form0.observacion2'+k).className = 'FormDataObjectDisabled';eval('document.form0.observacion2'+k).disabled=true;}}
function printDatos(){var fecha = document.form0.fecha.value;abrir_ventana1('../expediente/print_eval_ulceras.jsp?pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fechaEval='+fecha);}
function printDatosTodos(){abrir_ventana1('../expediente/print_eval_ulceras.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function add(){window.location = "../expediente/exp_eval_ulceras_x_presion.jsp?desc=<%=desc%>&pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&modeSec=add&mode=<%=mode%>";}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
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
				<%=fb.hidden("size",""+al.size())%>
				<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				<%=fb.hidden("dob","")%>
				<%=fb.hidden("codPac","")%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("usuarioCreacion",ulcera.getUsuarioCreacion())%>
				<%=fb.hidden("fechaCreacion",ulcera.getFechaCreacion())%>
				<%=fb.hidden("usuarioModificacion",ulcera.getUsuarioModificacion())%>
				<%=fb.hidden("fechaModificacion",ulcera.getFechaModificacion())%>
                <%=fb.hidden("desc",desc)%>
					<tr>
					<td  colspan="4">
					<div id="proc" width="100%" class="exp h100">
					<div id="proced" width="98%" class="child">

					 <table align="center" width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextHeader" align="center">
								<td width="20%"><cellbytelabel id="1">Fecha</cellbytelabel></td>
								<td width="80%"><cellbytelabel id="2">Observaci&oacute;n</cellbytelabel></td>
							</tr>
							<%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
							<%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
							<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')" style="cursor:pointer " onClick="javascript:setEvaluacion(0)" >
									<td><%=cDateTime.substring(0,10)%></td>
									<td><cellbytelabel id="3">Evaluaci&oacute;n actual</cellbytelabel></td>
							</tr>
<%}
al2 = CmnMgr.reverseRecords(iHashEval);
for (int i=1; i<=iHashEval.size(); i++)
{
	key = al2.get(i-1).toString();
	cdo = (CommonDataObject) iHashEval.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>

		<%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>


		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:setEvaluacion(<%=i%>)" >
				<td><%=cdo.getColValue("fecha")%></td>
				<td><%=cdo.getColValue("observacion")%></td>

		</tr>
<%
}
%>
						</table>

				</div>
		</div>
		</td>
		</tr>

			<tr class="TextRow01">
						<td colspan="3">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
						<td colspan="3" align="right">
						<%if(!mode.equals("view")){%>
						  <a href="javascript:add()" class="Link00"><cellbytelabel id="4">Agregar</cellbytelabel></a>&nbsp;&nbsp;&nbsp;
						<%}%>
						<a href="javascript:printDatosTodos()" class="Link00">[ <cellbytelabel id="5">Imprimir Todo</cellbytelabel> ]</a>&nbsp;&nbsp;&nbsp;<a href="javascript:printDatos()" class="Link00">[ <cellbytelabel id="6">Imprimir</cellbytelabel> ]</a></td>
				</tr>

				<tr class="TextRow01">
				<td colspan="3"><table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader">
						<td width="30%">&nbsp;</td>
						<td width="70%" align="center"><cellbytelabel id="7">Observaci&oacute;n General</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
						<td><cellbytelabel id="1">Fecha</cellbytelabel>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=ulcera.getFecha()%>" />
								</jsp:include></td>
							<td><%=fb.textarea("observacion",ulcera.getObservacion(),false,false,viewMode,18,2,2000,null,"width='100%'",null)%></td>
				 </tr>
						</table>
						</td>


				</tr>
                 <td colspan="4"><table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextRow01" align="left">
								<tr style="color:blue"><cellbytelabel id="8">G0= Piel &iacute;ntegra</cellbytelabel>.</tr>
								<tr style="color:blue"><cellbytelabel id="9">G1= Enrojecimiento de la piel. La misma permanece intacta</cellbytelabel></tr>
								<tr style="color:blue"><cellbytelabel id="10">G2= La &uacute;lcera es superficial. Aparece alg&uacute;n tipo de abrasi&oacute;n. La piel pierde la dermis y/o la epidermis.</cellbytelabel></tr>
								<tr style="color:blue"><cellbytelabel id="11">G3= La piel pierde con el da&ntilde;o o la necrosis su consistencia. Este da&ntilde;o no se extiende a mas all&aacute; de la fascia. Cl&iacute;nicamente la &uacute;lcera se ve como un cr&aacute;ter profundo que puede comprometer los tejidos adyacentes.</cellbytelabel></tr>
                <tr style="color:blue"><cellbytelabel id="12">G4= El grosor de la piel se pierde debido a la necrosis tisular y da&ntilde;o al m&uacute;sculo, hueso o estructuras de soporte. Hay compromiso de los tejidos adyacentes, asociados a f&iacute;stulas.</cellbytelabel></tr>
			</tr>

							<tr align="center" class="TextHeader">
								<td width="48%"><cellbytelabel id="13">Caracter&iacute;sticas</cellbytelabel></td>
								<td width="4%">S&iacute;</td>
								<td width="48%"><cellbytelabel id="2">Observaci&oacute;n</cellbytelabel></td>
							</tr>
			<tr>
					<td  colspan="3">
					<div id="listado" width="100%" class="exp h400">
					<div id="listadoDet" width="98%" class="child">

					 <table align="center" width="100%" cellpadding="1" cellspacing="1">

<%

for (int i=1; i<=al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

%>

<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("fechaUp"+i,cdo.getColValue("fechaUp"))%>
<%//=fb.hidden("seleccionar"+i,cdo.getColValue("seleccionar"))%>

							<tr class="<%=color%>">
							<td width="48%"><%=cdo.getColValue("descripcion")%></td>
								<td width="4%" align="center"><%=fb.checkbox("aplicar"+i,"S",(cdo.getColValue("seleccionar").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked("+i+")\"")%></td>

								<td width="48%"><%=fb.textarea("observacion2"+i,cdo.getColValue("observacion"),false,(!cdo.getColValue("seleccionar").equalsIgnoreCase("S")),viewMode,50,2,2000,null,"width='100%'",null)%></td>
							</tr>
<%
}
%>
						
				</table>
				</div>
				</div>
				</td>
				</tr>
						</table>
					</td>
				</tr>
				
				
				
				<tr class="TextRow02">
					<td colspan="2" align="right">
				<cellbytelabel id="14">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="15">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="16">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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
	String baction = request.getParameter("baction");
	int size= 0;

	fecha_eval = request.getParameter("fecha");
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));

	al.clear();
	UlceraPresion ulcer = new UlceraPresion();
		ulcer.setFechaNacimiento(request.getParameter("dob"));
		ulcer.setCodigoPaciente(request.getParameter("codPac"));
		ulcer.setSecuencia(request.getParameter("noAdmision"));
		ulcer.setFecha(request.getParameter("fecha"));
		ulcer.setObservacion(request.getParameter("observacion"));
		ulcer.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
		ulcer.setFechaCreacion(request.getParameter("fechaCreacion"));
		ulcer.setUsuarioModificacion((String) session.getAttribute("_userName"));
		ulcer.setFechaModificacion(cDateTime);

		ulcer.setPacId(request.getParameter("pacId"));

		for (int i=1; i<=size; i++)
		{
			if (request.getParameter("aplicar"+i)!= null && request.getParameter("aplicar"+i).equalsIgnoreCase("S"))
			{
				DetalleUlceras detUlcera = new DetalleUlceras();
				detUlcera.setFechaNacimiento(request.getParameter("dob"));
				detUlcera.setCodigoPaciente(request.getParameter("codPac"));
				detUlcera.setSecuencia(request.getParameter("noAdmision"));
				detUlcera.setFechaUp(request.getParameter("fecha"));
				detUlcera.setPacId(request.getParameter("pacId"));
				detUlcera.setCodConcepto(request.getParameter("codigo"+i));
				detUlcera.setObservacion(request.getParameter("observacion2"+i));
				detUlcera.setSeleccionar("S");
				try
				{
					al.add(detUlcera);
					ulcer.addDetalleUlceras(detUlcera);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//if
		}//for
		if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			if (modeSec.equalsIgnoreCase("add"))
			{
				ULCERMgr.add(ulcer);
			}
			else if (modeSec.equalsIgnoreCase("edit"))
			{
				ULCERMgr.update(ulcer);
			}
			ConMgr.clearAppCtx(null);
		}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ULCERMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ULCERMgr.getErrMsg()%>');
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
} else throw new Exception(ULCERMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval=<%=fecha_eval%>&desc=<%=desc%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval=<%=fecha_eval%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
