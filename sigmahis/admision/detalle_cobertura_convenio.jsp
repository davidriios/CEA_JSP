<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.CoberturaConvenio"%>
<%@ page import ="issi.admision.ConvenioSolBeneficio"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCob" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCob" scope="session" class="java.util.Vector" />
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />
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
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String cTab = request.getParameter("cTab");
String mode = request.getParameter("mode");
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String plan = request.getParameter("plan");
String categoriaAdm = request.getParameter("categoriaAdm");
String tipoAdm = request.getParameter("tipoAdm");
String clasifAdm = request.getParameter("clasifAdm");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String cod_pac = request.getParameter("cod_pac");
String admision = request.getParameter("admision");
String fecha_nacimiento = request.getParameter("fecha_nacimiento");
String secuencia_cob = request.getParameter("secuencia_cob");
String solicitud = request.getParameter("solicitud");
String secuencia_sol1 = request.getParameter("secuencia_sol1");
String cds = request.getParameter("cds");
String fechaNac="";
int cobLastLineNo = 0;
int exclLastLineNo = 0;
int defLastLineNo = 0;
String tipoCE = request.getParameter("tipoCE");
String ce = request.getParameter("ce");
int ceCDLastLineNo = 0;
String index = request.getParameter("index");
if (tab == null) tab = "0";
if (cTab == null) cTab = "0";
if (mode == null) mode = "add";
if (request.getParameter("cobLastLineNo") != null) cobLastLineNo = Integer.parseInt(request.getParameter("cobLastLineNo"));
if (change == null) change = "";
if (tipoCE == null) tipoCE = "";
if (ce == null) ce = "";
if (request.getParameter("ceCDLastLineNo") != null) ceCDLastLineNo = Integer.parseInt(request.getParameter("ceCDLastLineNo"));
if (index == null) index = "";
	fechaNac = fecha_nacimiento.substring(0,2)+"-"+fecha_nacimiento.substring(3,5)+"-"+fecha_nacimiento.substring(6,10);
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change.trim().equals(""))
	{
		iCob.clear();
		vCob.clear();

		sql="select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.codigo_paciente as codigoPaciente, a.admision  as admision, a.empresa as empresa, a.solicitud as solicitud, a.secuencia_cob as secuenciaCob, a.secuencia as secuencia, a.centro_servicio as centroServicio, a.tipo_servicio as tipoServicio, a.monto_pac as montoPac, a.tipo_val_pac as tipoValPac, a.monto_emp as montoEmp, a.tipo_val_emp as tipoValEmp, a.cobertura as tipoCobertura, a.pase as pase, a.pase_k as paseK, coalesce(c.descripcion,t.descripcion) as descripcion ,'1' as codigo from tbl_adm_cobertura_sol1 a ,tbl_cds_centro_servicio c,tbl_cds_tipo_servicio t where a.pac_id = "+pac_id+" and a.admision = "+admision+" and solicitud= "+solicitud+" and secuencia_cob="+secuencia_cob+" and a.centro_servicio = c.codigo(+) and  a.tipo_servicio= t.codigo (+) and a.empresa = "+empresa+" order by a.secuencia";
		//System.out.println("SQL:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,CoberturaConvenio.class);
		cobLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			CoberturaConvenio c =(CoberturaConvenio) al.get(i-1);
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			c.setKey(key);

			try
			{
				iCob.put(c.getKey(), c);
				vCob.add(c.getTipoCobertura()+((c.getCentroServicio() == null)?"":c.getCentroServicio())+((c.getTipoServicio() == null)?"":c.getTipoServicio()));
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}//for i
	}//change is null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'CONVENIO SOLICITUD DE BENEFICIO';

function addCob()
{
	setBAction('form0','+');
	form0BlockButtons(true);
	window.frames['iDetalle0'].doSubmit();
}

function removeCob(k)
{
	var tipoCobertura=eval('document.form0.tipoCobertura'+k).value;
	var retVal='<%=IBIZEscapeChars.forURL("count(*)")%>';
	var sec=eval('document.form0.secuencia'+k).value;
	var msg='';
	//if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_sol2','empresa=<%=empresa%> and admision=<%=admision%> and pac_id=<%=pac_id%> and solicitud=<%=solicitud%> and secuencia_cob=<%=secuencia_cob%> and secuencia_sol1=<%=secuencia_sol1%> and secuencia=\''+sec+'\'',''))msg+='\n- Cobertura solicitud 2';

	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_sol2','empresa=<%=empresa%> and admision=<%=admision%> and pac_id=<%=pac_id%> and solicitud=<%=solicitud%> and secuencia_cob=<%=secuencia_cob%> and secuencia_sol1=<%=secuencia_sol1%>',''))msg+='\n- Cobertura solicitud 2';

	//if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_sol3','empresa=<%=empresa%> and admision=<%=admision%> and pac_id=<%=pac_id%> and solicitud=<%=solicitud%> and secuencia_cob=<%=secuencia_cob%> and secuencia=\''+sec+'\'',''))msg+='\n- Cobertura solicitud 3';
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_sol3','empresa=<%=empresa%> and admision=<%=admision%> and pac_id=<%=pac_id%> and solicitud=<%=solicitud%> and secuencia_cob=<%=secuencia_cob%> and secuencia_sol1=<%=secuencia_sol1%>',''))msg+='\n- Cobertura solicitud 3';


	if(msg=='')
	{
		if(confirm('¿Está seguro de eliminar la Cobertura?'))
		{
			removeItem('form0',k);
			form0BlockButtons(true);
			window.frames['iDetalle0'].doSubmit();
		}
	}
	else CBMSG.warning('La Cobertura no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
}

function doAction()
{
}
function executeProc()
{
	var fechaNac= '<%=fechaNac%>';
	if(executeDB('<%=request.getContextPath()%>','call solicitud_benef_cob_sol0(\''+fechaNac+'\',<%=cod_pac%>,<%=admision%>,<%=solicitud%>,<%=pac_id%>)','tbl_adm_cobertura_sol1,tbl_adm_cobertura_sol2,tbl_adm_cobertura_sol3'))
	{
		CBMSG.warning('Los Parametros se han generado Satisfactoriamente');
		//window.location.reload(true);
		window.location = '../admision/detalle_cobertura_convenio.jsp?&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&empresa=<%=empresa%>&secuencia_cob=<%=secuencia_cob%>';
	}
	else CBMSG.warning('No se han Cargado los Datos');
	//window.location.reload(true);

}
function doSubmit(cTab,baction)
{
	setBAction('form0',baction);
	if(form0Validation())window.frames['iDetalle0'].doSubmit();
}
function showServiceList(cTab,k)
{
	var tipo = '';
	var fp = '';
		tipo = eval('document.form0.tipoCobertura'+k).value;
		fp = 'convenio_cobertura_solicitud';
	if (tipo == 'C') abrir_ventana2('../common/search_centro_servicio.jsp?fp='+fp+'&index='+k);
	else if (tipo == 'T') abrir_ventana2('../common/search_tipo_servicio.jsp?fp='+fp+'&index='+k);
}

function clearService(cTab,k)
{
	eval('document.form'+cTab+'.tipoServicio'+k).value = '';
	eval('document.form'+cTab+'.centroServicio'+k).value = '';
	eval('document.form'+cTab+'.codigo'+k).value = '';
	eval('document.form'+cTab+'.descripcion'+k).value = '';
}

function displayDetail(cTab,tipo,secuencia,k)
{
	var sec = eval('document.form0.secuencia'+k).value ;
	if (eval('document.form0.codigo'+k).value == '') CBMSG.warning('Por favor seleccione un Centro/Tipo de Servicio y guarde los cambios antes de agregar detalles!');

	else if (eval('document.form0.secuencia'+k).value == '0') CBMSG.warning('Por favor guarde los cambios antes de agregar detalles!');
	else if(eval('document.form0.tipoCobertura'+k).value == 'C')//quitar if si es para ambos (C o T)
	{
		var cds = eval('document.form0.centroServicio'+k).value ;
		setFrameSrc('iDetalle0','../admision/detalle_cobertura_centro.jsp?tab=<%=tab%>&cTab='+cTab+'&mode=<%=mode%>&tipoCobertura='+tipo+'&cobertura='+secuencia+'&index='+k+'&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&empresa=<%=empresa%>&secuencia_sol1='+sec+'&cds='+cds);
	}
	else if(eval('document.form0.tipoCobertura'+k).value == 'T')
	{
		var tipoServicio = eval('document.form0.tipoServicio'+k).value;
		//parent.showSelectBoxes(false);
		//showSelectBoxes(false);
		parent.showPopWin('../admision/detalle_cobertura_tipo.jsp?mode=<%=mode%>&tipoCobertura='+tipo+'&cobertura='+secuencia+'&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&empresa=<%=empresa%>&secuencia_sol1='+sec+'&tipoServicio='+tipoServicio,parent.winWidth*.95,parent.winHeight*.85,null,null,'');
		//parent.window.frames[\'iDetalle0\'].showSelectBoxes(true);parent.showSelectBoxes(true);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION SOLICITUD DE BENEFICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table width="100%" cellpadding="1" cellspacing="0">
<tr class="TextRow01">
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TextRow01">
		<div id="coberturas" style="overflow:scroll; position:static; height:250">
		<table width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("tab",tab)%>
		<%=fb.hidden("cTab","0")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("empresa",empresa)%>
		<%=fb.hidden("secuencia",secuencia)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("cobSize",""+iCob.size())%>
		<%=fb.hidden("cobLastLineNo",""+cobLastLineNo)%>
		<%=fb.hidden("errCode","")%>
		<%=fb.hidden("errMsg","")%>
		<%=fb.hidden("tipoCE","")%>
		<%=fb.hidden("ce","")%>
		<%=fb.hidden("index","")%>
		<%=fb.hidden("solicitud",solicitud)%>
		<%=fb.hidden("secuencia_cob",secuencia_cob)%>
		<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
		<%=fb.hidden("admision",admision)%>
		<%=fb.hidden("pac_id",pac_id)%>
		<%=fb.hidden("cod_pac",cod_pac)%>
		<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
		<%=fb.hidden("cds",cds)%>
		<tr class="TextRow02">
					<td colspan="8" align="right"><%=fb.button("addParam","Generar Parametros",true,false,null,null,"onClick=\"javascript:executeProc()\"")%>

		</tr>
		<tr class="TextHeader" align="center">
			<td width="5%">No.</td>
			<td width="17%">Cobertura Por</td>
			<td width="5%">C&oacute;d.</td>
			<td width="41%">Descripci&oacute;n</td>
			<td width="13%">Paciente</td>
			<td width="13%">Empresa</td>
			<td width="2%"></td>
			<td width="2%"><%=fb.button("addCobertura","+",true,false,null,null,"onClick=\"javascript:addCob()\"","Agregar Cobertura")%></td>
		</tr>
<%
int validCob = iCob.size();
al = CmnMgr.reverseRecords(iCob);
for (int i=1; i<=iCob.size(); i++)
{
	key = al.get(i - 1).toString();
	CoberturaConvenio c = (CoberturaConvenio) iCob.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
	String displayCob = "";
	if (c.getStatus() != null && c.getStatus().equalsIgnoreCase("D"))
	{
		displayCob = " style=\"display:none\"";
		validCob--;
	}
%>
		<%=fb.hidden("key"+i,c.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("status"+i,c.getStatus())%>
		<%=fb.hidden("tipoServicio"+i,c.getTipoServicio())%>
		<%=fb.hidden("expanded"+i,c.getExpanded())%>
		<%=fb.hidden("centroServicio"+i,c.getCentroServicio())%>
		<%=fb.hidden("secuencia"+i,c.getSecuencia())%>
		<tr class="<%=color%>" align="center"<%=displayCob%>>
			<td><%=c.getSecuencia()%></td>
			<td>
<%if (c.getSecuencia() != null && !c.getSecuencia().equals("0") || (c.getSecuencia() != null && c.getSecuencia().equals("0") && c.getCodigo() != null && !c.getCodigo().trim().equals(""))) {%>
				<%=fb.hidden("tipoCobertura"+i,c.getTipoCobertura())%>
				<%=(c.getTipoCobertura().equalsIgnoreCase("C"))?"CENTRO DE SERVICIO":"TIPO DE SERVICIO"%>
<%} else {%>
				<%=fb.select("tipoCobertura"+i,"C=CENTRO DE SERVICIO,T=TIPO DE SERVICIO",c.getTipoCobertura(),false,false,0,"Text10",null,"onChange=\"javascript:clearService(0,"+i+")\"")%>
<%}%>
			</td>
			<td><%=(c.getTipoCobertura().equalsIgnoreCase("T"))?fb.textBox("codigo"+i,c.getTipoServicio(),false,false,true,5,"Text10",null,null):fb.textBox("codigo"+i,c.getCentroServicio(),false,false,true,5,"Text10",null,null)%></td>
			<td>
				<%=fb.textBox("descripcion"+i,c.getDescripcion(),false,false,true,60,"Text10",null,null)%>
				<%=(c.getCodigo() != null && !c.getCodigo().trim().equals(""))?"":fb.button("btnService"+i,"...",true,false,null,null,"onClick=\"javascript:showServiceList(0,"+i+")\"")%></td>
			<td><%=fb.decBox("montoPac"+i,c.getMontoPac(),false,false,false,5,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValPac"+i,"P=%,M=$",c.getTipoValPac(),false,false,0,"Text10",null,null)%></td>
			<td><%=fb.decBox("montoEmp"+i,c.getMontoEmp(),false,false,false,5,11.2,"Text10",null,null)%>
						<%=fb.select("tipoValEmp"+i,"P=%,M=$",c.getTipoValEmp(),false,false,0,"Text10",null,null)%></td>
			<td onClick="javascript:displayDetail(0,'<%=c.getTipoCobertura()%>',<%=c.getSecuencia()%>,<%=i%>)" style="cursor:pointer"><img src="../images/dwn.gif" alt="Más Detalles de la Cobertura"></td>
			<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeCob('"+i+"')\"","Eliminar Cobertura")%></td>
		</tr>
<%
}
%>
		</table>
		</div>
<iframe id="iDetalle0" name="iDetalle0" width="100%" height="0" scrolling="no" frameborder="0" src="../admision/detalle_cobertura_centro.jsp?tab=<%=tab%>&cTab=0&mode=<%=mode%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobCDLastLineNo=<%=ceCDLastLineNo%>&index=<%=index%>&change=<%=change%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&empresa=<%=empresa%>&secuencia_sol1=<%=secuencia_sol1%>&cds=<%=cds%>"></iframe>



	</td>
</tr>
<tr class="TextRow02">
	<td align="right">
		Opciones de Guardar:
		<%--<%=fb.radio("saveOption","N")%>Crear Otro--%>
		<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
		<%=fb.radio("saveOption","C")%>Cerrar
		<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(0,this.value)\"")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
<!-- TAB0 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
initTabs('dhtmlgoodies_tabView1',Array('Coberturas'),<%=cTab%>,'100%','');
</script>

			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	String itemRemoved = "";
	ConvenioSolBeneficio cb = new ConvenioSolBeneficio();
	cb.setEmpresa(request.getParameter("empresa"));
	cb.setSolicitud(request.getParameter("solicitud"));
	if (cTab.equals("0")) //COBERTURAS
	{
		if (!request.getParameter("errCode").equals(""))
		{
			SBMgr.setErrCode(request.getParameter("errCode"));
			SBMgr.setErrMsg(request.getParameter("errMsg"));
		}
	}//cTab = 0

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SBMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SBMgr.getErrMsg()%>');
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
	window.close();
<%
	}
} else throw new Exception(SBMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?tab=<%=tab%>&cTab=<%=cTab%>&mode=edit&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoCE=<%=tipoCE%>&ce=<%=ce%>&index=<%=index%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&secuencia_sol1=<%=secuencia_sol1%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>