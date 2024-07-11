<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.UlceraPresion"%>
<%@ page import="issi.expediente.DetalleUlceras"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
document.title = 'Evaluacion de Ulceras por Presión - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function setEvaluacion(k){var fecha_e = eval('document.form0.fecha_evaluacion'+k).value ;window.location= '../expediente3.0/exp_eval_ulceras_x_presion.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval='+fecha_e+'&desc=<%=desc%>';}
function isChecked(k){
    if (!document.getElementById('aplicar'+k).checked){
        document.getElementById('observacion2'+k).value = "";
        document.getElementById('observacion2'+k).readOnly = true;
    } else { 
        document.getElementById('observacion2'+k).readOnly = false;
    }
}
function printDatos(){var fecha = document.form0.fecha.value;abrir_ventana1('../expediente/print_eval_ulceras.jsp?pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fechaEval='+fecha);}
function printDatosTodos(){abrir_ventana1('../expediente/print_eval_ulceras.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function add(){window.location = "../expediente3.0/exp_eval_ulceras_x_presion.jsp?desc=<%=desc%>&pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&modeSec=add&mode=<%=mode%>";}

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

<div class="headerform2">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
    <tr>
        <td>
        <%if(!mode.equals("view")){%>            
            <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
                <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
            </button>
        <%}%>
        <button type="button" class="btn btn-inverse btn-sm" onclick="printDatos()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
        <button type="button" class="btn btn-inverse btn-sm" onclick="printDatosTodos()"><i class="fa fa-print fa-printico"></i> <b>Imprimir Todo</b></button>
        </td>
	</tr>
</table>

<div class="table-wrapper">
  
    <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <thead> 
            <tr class="bg-headtabla2" align="center">
                <td width="20%"><cellbytelabel id="1">Fecha</cellbytelabel></td>
                <td width="80%"><cellbytelabel id="2">Observaci&oacute;n</cellbytelabel></td>
            </tr>
        </thead>
        <tbody>
        <%if(appendFilter.equals("1") && !op.trim().equals("0")){%>
            <%=fb.hidden("fecha_evaluacion0",cDateTime.substring(0,10))%>
            <tr class = "pointer" onclick = "javascript:setEvaluacion(0)">
                <td><%=cDateTime.substring(0,10)%></td>
                <td><cellbytelabel id="3">Evaluaci&oacute;n actual</cellbytelabel></td>
            </tr>
        <%}
        al2 = CmnMgr.reverseRecords(iHashEval);
        for (int i=1; i<=iHashEval.size(); i++){
            key = al2.get(i-1).toString();
            cdo = (CommonDataObject) iHashEval.get(key);
        %>
        <%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
        <%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
        <tr class="pointer" onClick="javascript:setEvaluacion(<%=i%>)" >
            <td><%=cdo.getColValue("fecha")%></td>
            <td><%=cdo.getColValue("observacion")%></td>
        </tr>
        <%}%>
       </tbody>
    </table>
</div>           
</div>
<table cellspacing="0" class="table table-small-font table-bordered table-striped">      

    <tr>
        <td class="controls form-inline">
            <cellbytelabel id="1">Fecha</cellbytelabel>
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fecha" />
            <jsp:param name="valueOfTBox1" value="<%=ulcera.getFecha()%>" />
            </jsp:include>
        </td>
        <td>
            <%=fb.textarea("observacion",ulcera.getObservacion(),false,false,viewMode,18,1,2000,"form-control input-sm","width:100%",null)%>
        </td>
     </tr>
     
     <tr>
        <td colspan="2"  style="color:blue; font-weight:bold">
        <cellbytelabel id="8">G0= Piel &iacute;ntegra</cellbytelabel>.<br>
        <cellbytelabel id="9">G1= Enrojecimiento de la piel. La misma permanece intacta</cellbytelabel><br>
        <cellbytelabel id="10">G2= La &uacute;lcera es superficial. Aparece alg&uacute;n tipo de abrasi&oacute;n. La piel pierde la dermis y/o la epidermis.</cellbytelabel><br>
        <cellbytelabel id="11">G3= La piel pierde con el da&ntilde;o o la necrosis su consistencia. Este da&ntilde;o no se extiende a mas all&aacute; de la fascia. Cl&iacute;nicamente la &uacute;lcera se ve como un cr&aacute;ter profundo que puede comprometer los tejidos adyacentes.</cellbytelabel><br>
        <cellbytelabel id="12">G4= El grosor de la piel se pierde debido a la necrosis tisular y da&ntilde;o al m&uacute;sculo, hueso o estructuras de soporte. Hay compromiso de los tejidos adyacentes, asociados a f&iacute;stulas.</cellbytelabel>
        </td>
     </tr>
 </table>

    <table cellspacing="0" class="table table-small-font table-bordered table-striped">  
    <tr class="bg-headtabla">
        <td width="48%"><cellbytelabel id="13">Caracter&iacute;sticas</cellbytelabel></td>
        <td width="4%">S&iacute;</td>
        <td width="48%"><cellbytelabel id="2">Observaci&oacute;n</cellbytelabel></td>
    </tr>
    
    <%
    for (int i=1; i<=al.size(); i++){
        cdo = (CommonDataObject) al.get(i-1);
    %>
    <%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
    <%=fb.hidden("fechaUp"+i,cdo.getColValue("fechaUp"))%>

    <tr>
        <td width="48%"><%=cdo.getColValue("descripcion")%></td>
        <td width="4%" align="center"><%=fb.checkbox("aplicar"+i,"S",(cdo.getColValue("seleccionar").equalsIgnoreCase("S")),viewMode,"form-control input-sm",null,"onClick=\"javascript:isChecked("+i+")\"")%></td>

        <td width="48%"><%=fb.textarea("observacion2"+i,cdo.getColValue("observacion"),false,false,(viewMode||cdo.getColValue("observacion").equals("")),50,1,2000,"form-control input-sm","width:100%",null)%></td>
    </tr>
<%
}
%>
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td>
                <input type="hidden" name="saveOption" value="O"> 
                <%=fb.submit("save","Guardar",true,viewMode,null,null,"")%>
            </td>    
        </tr>
    </table>
</div>
         
<%=fb.formEnd(true)%>
     
</div>
</div>           
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
<script>
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
