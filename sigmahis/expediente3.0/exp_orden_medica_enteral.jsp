<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

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
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
String id = request.getParameter("id");
String producto = request.getParameter("producto");
String cant = request.getParameter("cant");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (desc == null) desc = "";
if (modeSec == null) modeSec = "";
if (id == null) id = "0";
if (fg == null) fg = "0";
if (producto == null) producto = "";
if (cant == null) cant = "0";

if (mode == null || mode.trim().equals("")) mode = "add";
if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")){

    al2 = SQLMgr.getDataList("select a.codigo as cod_producto, b.codigo as id, a.descripcion as producto, to_char(b.fecha_creacion, 'dd/mm/yyy hh12:mi:ss am') fecha_creacion, to_char(b.fecha_modificacion, 'dd/mm/yyy hh12:mi:ss am') fecha_modificacion, b.usuario_creacion, b.usuario_modificacion,case when ceil(nvl(b.cifra_obtenidad, nvl(b.volumen_total, 0)/a.presentacion)) > 4.22 and a.alerta is not null then '<span style=''color:red;font-weight:bold;''>'||a.alerta||'</span>' else ceil(nvl(b.cifra_obtenidad,  nvl(b.volumen_total, 0)/a.presentacion))||' '||a.unidad_entrega end cantidad_a_entregar from tbl_sal_om_nutricional_enteral b, tbl_sal_productos_nutricional a where b.producto = a.codigo and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" order by b.codigo desc");

    CommonDataObject cdoP = new CommonDataObject();
    if (request.getParameter("producto") != null && !request.getParameter("producto").trim().equals("")) {
        cdoP = SQLMgr.getData("select a.descripcion, a.status, a.presentacion, a.presentacion_desc, a.unidad_entrega, nvl(b.volumen_total, "+cant+"*20) volumen_total, round(nvl(cifra_obtenidad,  nvl(b.volumen_total, "+cant+"*20)/a.presentacion),2) as cifra_obtenida, ceil(nvl(cifra_obtenidad,  nvl(b.volumen_total, "+cant+"*20)/a.presentacion)) as cifra_redondeada, a.alerta , decode(b.producto,null,'I','U') action, b.observacion, b.volumen_total/20 cant from tbl_sal_productos_nutricional a, tbl_sal_om_nutricional_enteral b where a.estado = 'A' and a.codigo = "+producto+" and a.codigo = b.producto(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo(+) = "+id);
        if (cdoP == null) cdoP = new CommonDataObject();
    }
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
var noNewHeight = true;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){
    //checkViewMode();
}

function verHistorial() {$("#hist_container").toggle();}
function consultar() {
    var producto = $("#tmp_producto").val();
    var cant = $("#tmp_cant").val() || '0';
    if (parseInt(cant) < 20 || parseInt(cant) > 80) parent.parent.CBMSG.error('Por ingresar un número entre 20 y 80.');
    else window.location = '../expediente3.0/exp_orden_medica_enteral.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&id=0&fg=consultar&seccion=<%=seccion%>&producto='+producto+'&cant='+cant+'&consultado=Y&mode=<%=mode%>&modeSec=<%=modeSec%>';
}

function cancelar() {
    window.location = '../expediente3.0/exp_orden_medica_enteral.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&id=0&fg=&seccion=<%=seccion%>&mode=<%=mode%>&modeSec=<%=modeSec%>';
}

function add() {
    window.location = '../expediente3.0/exp_orden_medica_enteral.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&id=0&fg=&seccion=<%=seccion%>&mode=<%=mode%>&modeSec=add';
}
function setOrden(id, producto) {
    window.location = '../expediente3.0/exp_orden_medica_enteral.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=&seccion=<%=seccion%>&mode=<%=mode%>&modeSec=view&id='+id+'&producto='+producto;
}

function printExp(){
    abrir_ventana('../expediente3.0/print_orden_medica_enteral.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&id=<%=id%>');
}
</script>
</head>
<body class="body-form">
  <div class="row">
    <div class="table-responsive" data-pattern="priority-columns">

        <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("baction","")%>
        <%=fb.hidden("mode",mode)%>
        <%=fb.hidden("modeSec",modeSec)%>
        <%=fb.hidden("seccion",seccion)%>
        <%=fb.hidden("pacId",pacId)%>
        <%=fb.hidden("noAdmision",noAdmision)%>
        <%=fb.hidden("fg",fg)%>
        <%=fb.hidden("desc",desc)%>
        <%=fb.hidden("id", id)%>
        <%=fb.hidden("producto", producto)%>
        <%=fb.hidden("cant", cant)%>
        <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
       <div class="headerform"> 
       <table cellspacing="0" class="table pull-right table-striped table-custom-1">
            <tr>
                <td class="controls form-inline">
                    <%if(!mode.trim().equals("view")){%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="add()"><i class="fa fa-plus fa-printico"></i> <b>Agregar</b></button>
                    <%}%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="printExp()"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></button>
                    
                    <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
                        <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
                    </button>
                 </td>
            </tr>
        </table>
    </div>
        
    <div class="table-wrapper" id="hist_container" style="display:none">
         <table class="table table-small-font table-bordered table-striped table-hover">
         <tr class="bg-headtabla2 pull-center">
			<td><cellbytelabel>ID</cellbytelabel></td>
            <td><cellbytelabel>Producto</cellbytelabel></td>
            <td><cellbytelabel>Cantida a entregar</cellbytelabel></td>
            <td><cellbytelabel>Creado el</cellbytelabel></td>
            <td><cellbytelabel>Creado Por</cellbytelabel></td>
            <td><cellbytelabel>Modificado el</cellbytelabel></td>
            <td><cellbytelabel>Creado Por</cellbytelabel></td>
         </tr>
         
         <% for (int a = 0; a < al2.size(); a++){
            cdo = (CommonDataObject)al2.get(a);
         %>
             <tr onClick="javascript:setOrden('<%=cdo.getColValue("id")%>', '<%=cdo.getColValue("cod_producto")%>')" class="pointer">
                 <td><%=cdo.getColValue("id")%></td>
                 <td><%=cdo.getColValue("producto")%></td>
                 <td><%=cdo.getColValue("cantidad_a_entregar")%></td>
                 <td><%=cdo.getColValue("fecha_creacion")%></td>
                 <td><%=cdo.getColValue("usuario_creacion")%></td>
                 <td><%=cdo.getColValue("fecha_modificacion")%></td>
                 <td><%=cdo.getColValue("usuario_modificacion")%></td>
             </tr>
		<%}%>
       </table>
    </div>
    
    <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <%if(id.equals("0") && request.getParameter("consultado") == null){%>
        <tr>
            <td width="30%"><b>Producto:</b></td>
            <td width="70%">
                <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_sal_productos_nutricional where estado = 'A' order by orden","tmp_producto","",false,false,0,"form-control input-sm","","",null,"S")%>
            </td>
        </tr>
        <tr>
            <td>
                <b>Indicaci&oacute;n M&eacute;dico Cant. 5x1: (c.c. o ml)</b>
            </td>
            <td>
                <%=fb.intBox("tmp_cant","",false,false,false,0,"form-control input-sm",null,null)%>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <button type="button" class="btn btn-inverse btn-sm" onclick="consultar()"><b>Consultar</b></button>
            </td>
        </tr>
        <%}%>
        
        <tr>
            <td width="30%">&nbsp;</td>
            <td width="40%">
                <table cellspacing="0" class="table table-bordered table-striped">
                    <tr>
                        <td width="50%"><b>Producto</b></td>
                        <td width="50%"><b><%=cdoP.getColValue("descripcion"," ")%></b></td>
                    </tr>
                    <tr>
                        <td width="50%"><b>Indicaci&oacute;n Médico Cant. 5x1: (c.c. o ml)</b></td>
                        <td width="50%"><b><%=cdoP.getColValue("cant",cant)%></b></td>
                    </tr>
                    <tr>
                        <td width="50%"><b>Volumen Total</b></td>
                        <td width="50%"><%=fb.textBox("volumen_total",cdoP.getColValue("volumen_total"," "),false,false,true,0,"form-control input-sm",null,null)%></td>
                    </tr>
                    <tr>
                        <td width="50%"><b>Presentaci&oacute;n</b></td>
                        <td width="50%"><%=fb.textBox("presentacion",cdoP.getColValue("presentacion"," ")+" "+cdoP.getColValue("presentacion_desc", " ").toLowerCase(),false,false,true,0,"form-control input-sm",null,null)%></td>
                    </tr>
                    <tr>
                        <td width="50%"><b>Estado</b></td>
                        <td width="50%"><%=fb.textBox("status",cdoP.getColValue("status"),false,false,true,0,"form-control input-sm",null,null)%></td>
                    </tr>
                    <%
                        String cantAentregar = cdoP.getColValue("cifra_redondeada"," ")+" "+cdoP.getColValue("unidad_entrega"," ");
                        String alertStyle = "";
                        
                        if (Double.parseDouble(cdoP.getColValue("cifra_redondeada","0")) > 4.22 && !cdoP.getColValue("alerta"," ").trim().equals("")) {
                            cantAentregar = cdoP.getColValue("alerta"," ");
                            alertStyle = "color: red;font-weight: bold;";
                        }
                    %>
                    <tr>
                        <td width="50%"><b>Cantidad a Entregar</b></td>
                        <td width="50%"><%=fb.textBox("cantida_a_entregar",cantAentregar,false,false,true,0,"form-control input-sm",alertStyle,null)%></td>
                    </tr>
                    <tr>
                        <td width="50%"><b>Cifra Obtenida</b></td>
                        <td width="50%"><%=fb.textBox("cifra_obtenida",cdoP.getColValue("cifra_obtenida", " "),false,false,true,0,"form-control input-sm",null,null)%></td>
                    </tr>
                    <tr>
                        <td width="50%"><b>Cifra redondeada</b></td>
                        <td width="50%"><%=fb.textBox("cifra_redondeada",cdoP.getColValue("cifra_redondeada", " "),false,false,true,0,"form-control input-sm",null,null)%></td>
                    </tr>
                    <tr>
                        <td colspan="2">
                           <b>Observaci&oacute;n:</b>
                           <%=fb.textarea("observacion",cdoP.getColValue("observacion"),false,false,viewMode,50,1,1000,"form-control input-sm",null,null)%>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <%=fb.hidden("saveOption","O")%>            
                            <%=fb.submit("save","Guardar",false,viewMode||producto.equals(""),"",null,"")%>
                            <%if(cdoP.getColValue("action"," ").equalsIgnoreCase("I")){%>
                                <button type="button" class="btn btn-inverse btn-sm" onclick="cancelar()"><b>Cancelar</b></button>
                            <%}%>
                        </td>
                    </tr>
                </table>
            </td>
            <td width="30%">&nbsp;</td>
        </tr>
    
    
    
    
    </table>
    
    
<%=fb.formEnd(true)%>
        
    </div>
  </div>
</body>
</html>
<%
} else {

    String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
    if (baction == null) baction = "";
    
    cdo = new CommonDataObject();
    cdo.setTableName("tbl_sal_om_nutricional_enteral");
    
    if (id.equals("0")) {
        CommonDataObject cdoN = SQLMgr.getData("select nvl(max(codigo),0)+1 next_code from tbl_sal_om_nutricional_enteral where pac_id = "+pacId+" and admision = "+noAdmision);
        cdo.addColValue("codigo", cdoN.getColValue("next_code"," "));
        cdo.addColValue("pac_id", pacId);
        cdo.addColValue("admision", noAdmision);
        cdo.addColValue("fecha_creacion", cDateTime);
        cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
        id = cdo.getColValue("codigo");
    } else {
        cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+id);
        cdo.addColValue("fecha_modificacion", cDateTime);
        cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
    }
    
    cdo.addColValue("producto", producto);
    cdo.addColValue("volumen_total", request.getParameter("volumen_total"));
    cdo.addColValue("cifra_obtenida", request.getParameter("cifra_obtenida"));
    cdo.addColValue("observacion", request.getParameter("observacion"));
    
    if (baction.equalsIgnoreCase("Guardar")) {
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        if (modeSec.equalsIgnoreCase("add")) {
            SQLMgr.insert(cdo);
        } else  {
            SQLMgr.update(cdo);
        }
        ConMgr.clearAppCtx(null);
    }
%>    
<html>
<head>
<script>
function closeWindow(){
<%if (SQLMgr.getErrCode().equals("1")){%>
	alert('<%=SQLMgr.getErrMsg()%>');
    
    <%if (saveOption.equalsIgnoreCase("N")){%>
	setTimeout('addMode()',500);
    <%}else if (saveOption.equalsIgnoreCase("O")){%>
	setTimeout('editMode()',500);
    <%}else if (saveOption.equalsIgnoreCase("C")){%>
	parent.doRedirect(0);
    <%}%>    
<%} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&producto=<%=producto%>&cant=<%=cant%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%}%>