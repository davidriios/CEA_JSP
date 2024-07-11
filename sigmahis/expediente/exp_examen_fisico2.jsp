<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.AreasCorporalPaciente"%>
<%@ page import="issi.expediente.CaracteristicasAreas"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="EFMgr" scope="page" class="issi.expediente.ExamenFisicoMgr" />
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
EFMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String tipo = request.getParameter("tipo");
String desc = request.getParameter("desc");
String descLabel = "EVALUACION FISICA";

if (mode == null) mode = "";
if (tipo == null) tipo = "";
if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode.trim().equals("")) mode = "add";
if (tipo.trim().equals("")) tipo = "M";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String cds = request.getParameter("cds");
String id = request.getParameter("id");

if (tipo.trim().equals("E")) descLabel += " - ENFERMERIA";

if(id== null)id="0";
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	sql="select distinct examen_id, to_char(fecha,'dd/mm/yyyy') fecha, to_char(fecha,'hh12:mi:ss am') hora from tbl_sal_examen_fisico where  pac_id="+pacId+" and admision= "+noAdmision+" and tipo ='"+tipo+"' order by examen_id desc";
	al2 = SQLMgr.getDataList(sql);

	sql="select a.codigo as codArea, 0 as codCarac, a.descripcion, nvl(b.normal,' ') as status, nvl(b.observacion,' ') as observacion,to_char(b.fecha,'dd/mm/yyyy hh12:mi am') fecha from tbl_sal_examen_areas_corp a, (select normal, cod_area, observacion,examen_id, fecha from tbl_sal_examen_fisico where examen_id(+) ="+id+"  and tipo ='"+tipo+"' ) b where a.codigo=b.cod_area(+) and a.codigo in (select cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+") and a.usado_por in('T','"+tipo+"') union select a.cod_area_corp, a.codigo, a.descripcion, nvl(b.seleccionar,' '), nvl(b.observacion,' '),' ' from tbl_sal_caract_areas_corp a, (select seleccionar, cod_area cod_area_corp, observacion, cod_caract cod_caract_corp from tbl_sal_examen_fisico_det where examen_id(+) = "+id+" ) b where a.cod_area_corp=b.cod_area_corp(+) and a.codigo=b.cod_caract_corp(+) and a.cod_area_corp in (select distinct cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+") and a.codigo in (select distinct cod_caract from tbl_sal_caract_area_corp_x_cds where cod_area=a.cod_area_corp and centro_servicio="+cds+") and a.usado_por in('T','"+tipo+"') ";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - Evaluacion Física - '+document.title;
function doAction(){newHeight();}
function showDetail(k,status){var area=eval('document.form0.codArea'+k).value;var obj=document.getElementById('detail'+area);if(status=='N'){eval('document.form0.observacion'+k).readOnly=false;eval('document.form0.observacion'+k).className='FormDataObjectEnabled';obj.style.display='none';}else if(status=='A'){eval('document.form0.observacion'+k).readOnly=true;eval('document.form0.observacion'+k).className='FormDataObjectDisabled';eval('document.form0.observacion'+k).value='';obj.style.display='';}else{eval('document.form0.observacion'+k).readOnly=true;eval('document.form0.observacion'+k).className='FormDataObjectDisabled';eval('document.form0.observacion'+k).value='';obj.style.display='none';}doAction();}
function showObservation(k){if(eval('document.form0.status'+k).checked){eval('document.form0.observacion'+k).readOnly=false;eval('document.form0.observacion'+k).className='FormDataObjectEnabled';}else{eval('document.form0.observacion'+k).readOnly=true;eval('document.form0.observacion'+k).className='FormDataObjectDisabled';eval('document.form0.observacion'+k).value='';}}
function verifyObservation(){var error=0;for(i=0;i<<%=al.size()%>;i++){if(eval('document.form0.codCarac'+i).value!='0'){if(eval('document.form0.status'+i).checked&&eval('document.form0.observacion'+i).value.trim()==''){error++;break;}}}if(error>0)return false;else return true;}
function setEvaluacion(code){window.location = '../expediente/exp_examen_fisico2.jsp?modeSec=view&mode=<%=mode%>&tipo=<%=tipo%>&desc=<%=desc%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&id='+code;}
function add(){window.location = '../expediente/exp_examen_fisico2.jsp?modeSec=add&mode=<%=mode%>&tipo=<%=tipo%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&id=0&desc=<%=desc%>';}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr class="TextRow01">
					<td  colspan="5">
					<div id="proc" width="100%" class="exp h100">
					<div id="proced" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
						<%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
						<tr class="TextRow02">
							<td colspan="3">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
							<td align="right"><%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel> ]</a><%}%></td>
						</tr>

						<tr class="TextHeader">
							<td  width="5%">&nbsp;</td>
							<td  width="15%"><cellbytelabel id="3">Fecha</cellbytelabel></td>
							<td  width="15%"><cellbytelabel id="4">Hora</cellbytelabel></td>
							<td  width="65%">&nbsp;</td>
						</tr>
<%
for (int i=1; i<=al2.size(); i++)
{
	CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("id"+i,cdo1.getColValue("examen_id"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=cdo1.getColValue("examen_id")%>)" style="text-decoration:none; cursor:pointer">
				<td><%=i%></td>
				<td><%=cdo1.getColValue("fecha")%></td>
				<td colspan="2"><%=cdo1.getColValue("hora")%></td>

		</tr>
<%}%>

			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>



<tr>
	<td colspan="5">
			<table width="100%" cellpadding="1" cellspacing="1" >
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("cds",""+cds)%>
<%=fb.hidden("id",""+id)%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02" >
			<td colspan="5">&nbsp;</td>
		</tr>
		<%if(mode.trim().equals("add")){%>
		<tr class="TextRow02" >
			<td><cellbytelabel id="3">Fecha</cellbytelabel>&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="format" value="dd/mm/yyyy"/>
										<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
										<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
										</jsp:include></td>

							<td colspan="4">
										<cellbytelabel id="4">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;
										<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1"/>
										<jsp:param name="format" value="hh12:mi am"/>
										<jsp:param name="nameOfTBox1" value="hora" />
										<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(11)%>" />
										<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
										</jsp:include>
						 </td>
		</tr>
		<%}%>
		<tr class="TextHeader" align="center" >
			<td width="35%"><cellbytelabel id="5">&Aacute;rea</cellbytelabel></td>
			<td width="7%" class="Text10"><cellbytelabel id="6">No Evaluado</cellbytelabel></td>
			<td width="7%" class="Text10"><%=(tipo.trim().equals("E"))?"Gral":"Normal"%></td>
			<td width="7%" class="Text10"><%=(tipo.trim().equals("E"))?"Detalle":"Anormal"%></td>
			<td width="44%"><cellbytelabel id="7">Observaci&oacute;n del &Aacute;rea</cellbytelabel></td>
		</tr>
		<!---<tr>
		<td colspan="5">
		<div id="areas" width="100%" style="overflow:scroll;position:relative;height:200">
					<div id="detareas" width="98%" style="overflow;position:absolute">
					<table width="100%" cellpadding="1" cellspacing="1" >--->
<%
String area = "",fecha="";
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
//	if (i % 2 == 0) color = "TextRow01";
	boolean isReadOnly = false;
	String displayDetail = "none";
	if (cdo.getColValue("codCarac").equals("0"))
	{
		isReadOnly = (viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("N"));
		if (cdo.getColValue("status").trim().equalsIgnoreCase("A")) displayDetail = "''";
	}
	else
	{
		isReadOnly = (viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("S"));
	}
%>
				<%=fb.hidden("codArea"+i,cdo.getColValue("codArea"))%>
				<%=fb.hidden("codCarac"+i,cdo.getColValue("codCarac"))%>
				<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
<%
	if (area.equals(cdo.getColValue("codArea")))
	{
%>
				<tr class="TextRow01">
					<td>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("descripcion")%></td>
					<td align="center"><%=fb.checkbox("status"+i,"S",cdo.getColValue("status").trim().equalsIgnoreCase("S"),viewMode,null,null,"onClick=\"javascript:showObservation("+i+")\"")%></td>
					<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("S")),60,1,2000,"","width:100%","")%></td>
				</tr>
<%
	}
	else
	{
		if (i != 0)
		{
%>
				</table>
			</td>
		</tr>
<%
		}
%>
		<tr class="<%=color%>">
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=fb.radio("status"+i,"",cdo.getColValue("status").trim().equals(""),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td align="center"><%=fb.radio("status"+i,"S",cdo.getColValue("status").trim().equalsIgnoreCase("N"),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td align="center"><%=fb.radio("status"+i,"N",cdo.getColValue("status").trim().equalsIgnoreCase("A"),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("N")),60,1,2000,"","width:100%","")%></td>
		</tr>
		<tr id="detail<%=cdo.getColValue("codArea")%>" style="display:<%=displayDetail%>">
			<td colspan="5">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02" align="center">
					<td width="45%"><cellbytelabel id="8">Caracter&iacute;sticas Anormales</cellbytelabel></td>
					<td width="5%"><cellbytelabel id="9">S&iacute;</cellbytelabel></td>
					<td width="50%"><cellbytelabel id="10">Observaci&oacute;n</cellbytelabel></td>
				</tr>
<%
	}
	if (i + 1 == al.size())
	{
%>
				</table>
			</td>
		</tr>
<%
	}
	area = cdo.getColValue("codArea");
}//for
%>
<!---</table>
</td></tr>
</div>
</div>--->
		<tr class="TextRow02" align="right">
			<td colspan="5">
				<cellbytelabel id="11">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="12">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="13">Cerrar</cellbytelabel>
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
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));

	Hashtable htHash = new Hashtable();
	al.clear();
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("codCarac"+i).equals("0"))
		{
			if (!request.getParameter("status"+i).trim().equals(""))
			{
				AreasCorporalPaciente area = new AreasCorporalPaciente();

				area.setPacId(request.getParameter("pacId"));
				area.setSecuencia(request.getParameter("noAdmision"));
//				area.setCodCaractCorp(request.getParameter("codCarac"+i));
				area.setCodArea(request.getParameter("codArea"+i));
				area.setObservaciones(request.getParameter("observacion"+i));
				area.setNormal(request.getParameter("status"+i));
				//area.setTipo(tipo);
				if (modeSec.equalsIgnoreCase("add"))
				{
					area.setFecha(request.getParameter("fecha")+" "+request.getParameter("hora"));
				}else
				{
				 	if(request.getParameter("fecha"+i) != null && !request.getParameter("fecha"+i).trim().equals(""))
					area.setFecha(request.getParameter("fecha"+i));
					else area.setFecha(cDateTime);
				}
				try
				{
					htHash.put(area.getCodArea(), area);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//area
		else
		{
			if (request.getParameter("status"+i) != null)
			{
				CaracteristicasAreas carac = new CaracteristicasAreas();

				carac.setCodCaractCorp(request.getParameter("codCarac"+i));
				carac.setObservacion(request.getParameter("observacion"+i));
				carac.setCodAreaCorp(request.getParameter("codArea"+i));
				carac.setValor(request.getParameter("valor"+i));
				carac.setSeleccionar(request.getParameter("status"+i));

				try
				{
					AreasCorporalPaciente area = (AreasCorporalPaciente) htHash.get(carac.getCodAreaCorp());//

					if (area.getNormal().equals("A"))
					{
						area.addCaracteristicasAreas(carac);
					}

					htHash.put(area.getCodArea(),area);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
	}//for
System.out.println(" tamaño del has table ===="+htHash.size()+" id   =  "+id);
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		EFMgr.addExamen(htHash,id);
		if(modeSec.trim().equals("add"))
		id = EFMgr.getPkColValue("id");

		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (EFMgr.getErrCode().equals("1"))
{
%>
	alert('<%=EFMgr.getErrMsg()%>');
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
} else throw new Exception(EFMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&tipo=<%=tipo%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&id=<%=id%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>


