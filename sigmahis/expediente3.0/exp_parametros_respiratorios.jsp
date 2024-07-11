<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.expediente.EvolucionParametros"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="EPMgr" scope="page" class="issi.expediente.EvolucionParametrosMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
EPMgr.setConnection(ConMgr);
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
String groupId = request.getParameter("groupId");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String key ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

String paramRespDet = "N";
try {paramRespDet =java.util.ResourceBundle.getBundle("issi").getString("auto.pram.resp");}catch(Exception e){ paramRespDet = "N";}

if (groupId == null) groupId = "0";
if (desc == null) desc = "";
if (mode == null) mode = "";
if (modeSec == null ||modeSec.trim().equals(""))modeSec = "add";
if (mode.trim().equals(""))mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql="select distinct grupo_id, modo_id,b.descripcion descModo,to_char(a.fecha,'dd/mm/yyyy hh12:mi:ss am') fecha from tbl_sal_evolucion_respiratorio a , tbl_sal_modo_ventilacion b where b.id = a.modo_id and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and  a.ref_type ='RES' order by a.grupo_id desc   ";

	al2 = SQLMgr.getDataList(sql);

	sql = "select nvl(b.tiene_detalle,'N') has_det, a.codigo_uso, b.id,a.parametro_id as id_param,a.estado,a.code_det, a.grupo_id,a.modo_id, a.pac_id,a.admision, to_char(a.fecha,'dd/mm/yyyy')fecha ,to_char(a.fecha,'hh12:mi am')hora, a.valor,b.descripcion,decode(a.parametro_id,null,'I','U') as action, nvl((select join(cursor(select z.code||'='||z.descripcion||'='||z.codigo_uso from tbl_sal_evolucion_param_det z  where z.id_param = b.id and z.estado <> decode(a.parametro_id,null,'I','T') ),',') as detalle from dual),' ') as detalle,nvl(( select  z.descripcion  from tbl_sal_evolucion_param_det z  where z.id_param = a.parametro_id  and z.code=a.code_det and z.estado <> decode(a.parametro_id,null,'I','T') ),a.valor) as valorDesc,(select max(grupo_id) from tbl_sal_evolucion_respiratorio where pac_id="+pacId+" and admision="+noAdmision+" and estado ='T') grupoIdOld from tbl_sal_evolucion_respiratorio a, tbl_sal_evolucion_parametro b where b.id = a.parametro_id(+) and b.tipo = 'RE' and a.pac_id(+) = "+pacId+" and a.admision(+) = "+noAdmision+(!groupId.trim().equals("")?" and a.grupo_id(+) = "+groupId:" ")+" and  a.ref_type(+) ='RES' order by b.orden";
	al = SQLMgr.getDataList(sql);

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
document.title = 'EXPEDIENTE - Evolucion  Hemodinamica - '+document.title;
var noNewHeight = true;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function setEvaluacion(id){	window.location = '../expediente3.0/exp_parametros_respiratorios.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&cds=<%=cds%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&groupId='+id+'&desc=<%=desc%>';}
function add(){window.location = '../expediente3.0/exp_parametros_respiratorios.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&cds=<%=cds%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&groupId=0&desc=<%=desc%>';}
function verEvol(){abrir_ventana1('../expediente/exp_parametros_hemo_resp_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=RE');}
function imprimirExp(opt){
    var fDate = $("#f_desde").val();
    var tDate = $("#f_hasta").val();
    if (!opt) {
        abrir_ventana1('../expediente/print_exp_seccion_61.jsp?refType=RES&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&groupId=<%=groupId%>');
    } else {
        if(fDate && tDate) abrir_ventana1('../expediente/print_exp_seccion_61.jsp?refType=RES&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&f_date='+fDate+'&t_date='+tDate);
    }
}
function setValorValue(ind,obj){
<%if(paramRespDet.trim().equals("S")){%>
var cod_uso = getSelectedOptionTitle(obj,'');
if(cod_uso!=''){document.getElementById("codigo_uso"+ind).value=cod_uso;}
else document.getElementById("codigo_uso"+ind).value = "";
<%}%>
}
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
<%=fb.hidden("groupId",""+groupId)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("desc",desc)%>

<div class="headerform2">

    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
        <tr>
            <td class="controls form-inline">
               <%if(!mode.trim().equals("view")){%>                   
                   <button type="button" name="addEval" id="addEval" class="btn btn-inverse btn-sm" onclick="javascript:add()"<%=mode.trim().equals("view")?" disabled":""%>>
                <i class="fa fa-plus fa-lg"></i> <cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel>
            </button>
                   
			   <%} if(al2.size() > 0){%>
               Desde
               <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
                    <jsp:param name="nameOfTBox1" value="f_desde" />
                    <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,19)%>" />
                    <jsp:param name="clearOption" value="true" />
                </jsp:include>
                Hasta
               <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
                    <jsp:param name="nameOfTBox1" value="f_hasta" />
                    <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,19)%>" />
                     <jsp:param name="clearOption" value="true" />
                </jsp:include>
                    <%if(!groupId.trim().equals("") && !groupId.equals("0")){%>
                    <%=fb.button("imprimir","Imprimir",false,false,null,null,"onClick=\"javascript:imprimirExp()\"")%>
                    <%}%>
                    <button type="button" name="imprimir-all" id="imprimir-all" value="Imprimir" class="btn btn-inverse btn-sm" onclick="javascript:imprimirExp(1)"><i class="fa fa-print fa-lg"></i> Imprimir Todo</button>
               <%}%>
            </td>
        </tr>
        <tr class="bg-headtabla"><th>Listado de Evaluaciones</th></tr>
    </table>

    <div class="table-wrapper">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <thead>
            <tr class="bg-headtabla2">
                <td width="15%"><cellbytelabel id="4">Fecha / Hora</cellbytelabel></td>
                <td width="70%"><cellbytelabel id="5">Modo Ventilaci&oacute;n</cellbytelabel></td>
            </tr>
        </thead>    
        <tbody>    
        <% for (int i=1; i<=al2.size(); i++){
            CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);%>
            <tr class="pointer" onClick="javascript:setEvaluacion(<%=cdo1.getColValue("grupo_id")%>)">
				<td><%=cdo1.getColValue("fecha")%></td>
				<td><%=cdo1.getColValue("descModo")%></td>
            </tr>
        <%}%>
		</tbody>
		</table>
    </div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">		
<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
		if(i==0)
		{
		%>
		<tr class="TextRow01">
			<td width="40%" class="controls form-inline"><cellbytelabel id="6">Fecha</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;

						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fecha" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha") == null || cdo.getColValue("fecha").trim().equals("")?cDateTime.substring(0,10):cdo.getColValue("fecha"))%>" />
						<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
						</jsp:include>  </td>
			<td width="60%" class="controls form-inline"><cellbytelabel id="7">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="hh12:mi am"/>
						<jsp:param name="nameOfTBox1" value="hora" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora") == null || cdo.getColValue("hora").trim().equals("")?cDateTime.substring(11):cdo.getColValue("hora"))%>" />
						<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
						</jsp:include>


			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2" class="controls form-inline"><cellbytelabel id="5">Modo Ventilaci&oacute;n</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;
			<%=fb.select(ConMgr.getConnection(),"SELECT id, codigo||' - '||descripcion, id FROM tbl_sal_modo_ventilacion ORDER BY 1 ","modo_id",cdo.getColValue("modo_id"),false,viewMode,0,"form-control input-sm",null,null,"","")%>
			</td>
		</tr>

		<tr class="bg-headtabla">
			<td width="40%"><cellbytelabel id="8">Descripci&oacute;n</cellbytelabel></td>
			<td width="60%" align="center"><cellbytelabel id="9">Valor</cellbytelabel></td>
		</tr>
		<%
		}

		%>
		<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("codigo_uso"+i,cdo.getColValue("codigo_uso"))%>
		<%=fb.hidden("has_det"+i,cdo.getColValue("has_det"))%>
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("code_det"+i,cdo.getColValue("code_det"))%>
		<%=fb.hidden("detalle"+i,cdo.getColValue("detalle"))%>
		<%=fb.hidden("codigo_uso_old"+i,cdo.getColValue("codigo_uso"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("id_param"+i,cdo.getColValue("id_param"))%>
		<%=fb.hidden("grupoIdOld"+i,cdo.getColValue("grupoIdOld"))%>
		
		<tr class="<%=color%>">
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center" class="controls form-inline">
			 <%if((cdo.getColValue("has_det")!=null && cdo.getColValue("has_det").equals("S") && cdo.getColValue("detalle") != null && !cdo.getColValue("detalle").trim().equals("") ) && paramRespDet.trim().equals("S")&&!modeSec.trim().equals("view")){%>
			 <%=fb.select("valor"+i,cdo.getColValue("detalle"),cdo.getColValue("code_det"),false,false,viewMode,0,"form-control input-sm",null,"onChange=\"javascript:setValorValue("+i+",this)\"","","S")%>
			 <%}else{%>
				<%=fb.textBox("valor"+i,((modeSec.trim().equals("view"))?cdo.getColValue("valorDesc"):cdo.getColValue("valor")),false,false,viewMode,30,30,"form-control input-sm","","")%>
			 <%}%>
			</td>
		</tr>
<%
}
%>
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
            <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
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
	int size= Integer.parseInt(request.getParameter("size"));
	al.clear();

	for (int i=0; i<size; i++)
	{
		if (request.getParameter("valor"+i) != null && !request.getParameter("valor"+i).trim().equals(""))
		{
			EvolucionParametros eph = new EvolucionParametros();

			eph.setGrupoId(request.getParameter("groupId"));
			eph.setParametroId(request.getParameter("id"+i));
			eph.setPacId(request.getParameter("pacId"));
			eph.setAdmision(request.getParameter("noAdmision"));
			
			eph.setAction(request.getParameter("action"+i));
			eph.setValor(request.getParameter("valor"+i));
			eph.setCodigoUso(request.getParameter("codigo_uso"+i));
			eph.setCodigoUsoOld(request.getParameter("codigo_uso_old"+i));
			//eph.setCodeDet(request.getParameter("code_det"+i));								
			eph.setFecha(request.getParameter("fecha"));
			eph.setHora(request.getParameter("hora"));
			eph.setModoId(request.getParameter("modo_id"));
			eph.setRefType("RES");
			if(paramRespDet.trim().equals("S"))eph.setGenerarCargo("S");
			else eph.setGenerarCargo("N");
			eph.setCds(cds);
			eph.setCompania((String)session.getAttribute("_companyId"));
			eph.setUsuarioModifica((String) session.getAttribute("_userName"));

			if(request.getParameter("id_param"+i)==null||request.getParameter("id_param"+i).trim().equals(""))
			{
				eph.setEstado("T");
				eph.setUsuarioCreacion((String) session.getAttribute("_userName"));
			}else{ eph.setEstado(request.getParameter("estado"+i));}
			
			if((request.getParameter("has_det"+i)!=null && request.getParameter("has_det"+i).equals("S") && request.getParameter("detalle"+i) != null && !request.getParameter("detalle"+i).trim().equals("") ) && paramRespDet.trim().equals("S")){
			eph.setDetalleOld(request.getParameter("code_det"+i));
			eph.setCodeDet(request.getParameter("valor"+i));
			
			if(paramRespDet.trim().equals("S")&&request.getParameter("valor"+i).trim().equals("0"))
			{eph.setGenerarCargo("S");eph.setGrupoIdOld(request.getParameter("grupoIdOld"+i));}else eph.setGenerarCargo("N");
			
			}else eph.setCodeDet("null");
			
			al.add(eph);
		}
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
    {
		EPMgr.addParam(al,modeSec);
		groupId = EPMgr.getPkColValue("grupoId");
	}
	else if (modeSec.equalsIgnoreCase("edit")) EPMgr.addParam(al,modeSec);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (EPMgr.getErrCode().equals("1"))
{
%>
	alert('<%=EPMgr.getErrMsg()%>');
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
} else throw new Exception(EPMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&groupId=<%=groupId%>&cds=<%=cds%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
