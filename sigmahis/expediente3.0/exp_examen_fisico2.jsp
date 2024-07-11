<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.AreasCorporalPaciente"%>
<%@ page import="issi.expediente.CaracteristicasAreas"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
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
<!DOCTYPE html>
<html lang="en"> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
document.title = 'EXPEDIENTE - Evaluacion Física - '+document.title;
var noNewHeight = true;
function doAction(){}
function showDetail(k,status){var area=eval('document.form0.codArea'+k).value;var obj=document.getElementById('detail'+area);if(status=='N'){eval('document.form0.observacion'+k).readOnly=false;eval('document.form0.observacion'+k).className='FormDataObjectEnabled form-control input-sm';obj.style.display='none';}else if(status=='A'){eval('document.form0.observacion'+k).readOnly=true;eval('document.form0.observacion'+k).className='FormDataObjectDisabled form-control input-sm';eval('document.form0.observacion'+k).value='';obj.style.display='';}else{eval('document.form0.observacion'+k).readOnly=true;eval('document.form0.observacion'+k).className='FormDataObjectDisabled form-control input-sm';eval('document.form0.observacion'+k).value='';obj.style.display='none';}doAction();}
function showObservation(k){if(eval('document.form0.status'+k).checked){eval('document.form0.observacion'+k).readOnly=false;eval('document.form0.observacion'+k).className='FormDataObjectEnabled form-control input-sm';}else{eval('document.form0.observacion'+k).readOnly=true;eval('document.form0.observacion'+k).className='FormDataObjectDisabled form-control input-sm';eval('document.form0.observacion'+k).value='';}}
function verifyObservation(){var error=0;for(i=0;i<<%=al.size()%>;i++){if(eval('document.form0.codCarac'+i).value!='0'){if(eval('document.form0.status'+i).checked&&eval('document.form0.observacion'+i).value.trim()==''){error++;break;}}}if(error>0)return false;else return true;}
function setEvaluacion(code){window.location = '../expediente3.0/exp_examen_fisico2.jsp?modeSec=view&mode=<%=mode%>&tipo=<%=tipo%>&desc=<%=desc%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&id='+code;}
function add(){window.location = '../expediente3.0/exp_examen_fisico2.jsp?modeSec=add&mode=<%=mode%>&tipo=<%=tipo%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&id=0&desc=<%=desc%>';}
</script>
</head>
<body class="body-forminside" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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

<div class="headerform2">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
    <tr>
        <td>
        <%if(!mode.trim().equals("view")){%>
          <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
            <i class="fa fa-plus fa-printico"></i> <b>Agregar Evaluaci&oacute;n</b>
          </button>
        <%}%>
        </td>
    </tr>
    <tr><th class="bg-headtabla">Listado de Evaluaciones</th></tr>
</table>

<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
    <tr class="bg-headtabla2">
    <th style="vertical-align: middle !important;">C&oacute;digo</th>
    <th style="vertical-align: middle !important;">Fecha</th>
    <th style="vertical-align: middle !important;">Hora</th>
    </thead>
<tbody>
<%
for (int i=1; i<=al2.size(); i++){
	CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);
%>
		<tr onClick="javascript:setEvaluacion(<%=cdo1.getColValue("examen_id")%>)" class="pointer">
            <td><%=cdo1.getColValue("examen_id")%></td>
            <td><%=cdo1.getColValue("fecha")%></td>
            <td><%=cdo1.getColValue("hora")%></td>
		</tr>
<%}%>
</tbody>
</table>
</div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
 <tbody>
<%if(mode.trim().equals("add")){%>
<tr>
    <td class="controls form-inline" colspan="5">
        <cellbytelabel id="3">Fecha</cellbytelabel>&nbsp;<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="fecha" />
        <jsp:param name="format" value="dd/mm/yyyy"/>
        <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
        <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
        </jsp:include>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <cellbytelabel id="4">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;
        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1"/>
        <jsp:param name="format" value="hh12:mi am"/>
        <jsp:param name="nameOfTBox1" value="hora" />
        <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(11)%>" />
        <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
        </jsp:include>
    </td>
</tr>
<%}%>
<tr class="bg-headtabla2">
    <th><cellbytelabel id="5">&Aacute;rea</cellbytelabel></th>
    <th><cellbytelabel id="6">No Evaluado</cellbytelabel></th>
    <th><%=(tipo.trim().equals("E"))?"Gral":"Normal"%></th>
    <th><%=(tipo.trim().equals("E"))?"Detalle":"Anormal"%></th>
    <th><cellbytelabel id="7">Observaci&oacute;n del &Aacute;rea</cellbytelabel></th>
</tr>
<%
String area = "",fecha="";
for (int i=0; i<al.size(); i++){
	cdo = (CommonDataObject) al.get(i);
	boolean isReadOnly = false;
	String displayDetail = "none";
	if (cdo.getColValue("codCarac").equals("0")){
		isReadOnly = (viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("N"));
		if (cdo.getColValue("status").trim().equalsIgnoreCase("A")) displayDetail = "''";
	}
	else{
		isReadOnly = (viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("S"));
	}
%>
    <%=fb.hidden("codArea"+i,cdo.getColValue("codArea"))%>
    <%=fb.hidden("codCarac"+i,cdo.getColValue("codCarac"))%>
    <%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
<%
	if (area.equals(cdo.getColValue("codArea"))){
%>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("descripcion")%></td>
        <td align="center"><%=fb.checkbox("status"+i,"S",cdo.getColValue("status").trim().equalsIgnoreCase("S"),viewMode,null,null,"onClick=\"javascript:showObservation("+i+")\"")%></td>
        <td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("S")),60,1,2000,"form-control input-sm","width:100%","")%></td>
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
		<tr>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=fb.radio("status"+i,"",cdo.getColValue("status").trim().equals(""),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td align="center"><%=fb.radio("status"+i,"S",cdo.getColValue("status").trim().equalsIgnoreCase("N"),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td align="center"><%=fb.radio("status"+i,"N",cdo.getColValue("status").trim().equalsIgnoreCase("A"),viewMode,false,null,null,"onClick=\"javascript:showDetail("+i+",this.value)\"")%></td>
			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || !cdo.getColValue("status").trim().equalsIgnoreCase("N")),60,1,2000,"form-control input-sm","width:100%","")%></td>
		</tr>
		<tr id="detail<%=cdo.getColValue("codArea")%>" style="display:<%=displayDetail%>">
			<td colspan="5">
				<table class="table table-bordered table-striped">
				<tr class="bg-headtabla2" align="center">
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

<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
        <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
        <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
    </tr>
    </table> </div>

<%=fb.formEnd(true)%>
		
</div>
</div>
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