<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.CoberturaConvenio"%>
<%@ page import="issi.admision.ConvenioSolBeneficio"%>
<%@ page import="issi.admision.DetalleCoberturaConvenio"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />
<jsp:useBean id="iCobCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobCD" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCob" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCob" scope="session" class="java.util.Vector" />
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
String tipoCobertura = request.getParameter("tipoCobertura");
String index = request.getParameter("index");
String change = request.getParameter("change");
int cobCDLastLineNo = 0;
String pac_id = request.getParameter("pac_id");
String cod_pac = request.getParameter("cod_pac");
String admision = request.getParameter("admision");
String fecha_nacimiento = request.getParameter("fecha_nacimiento");
String secuencia_cob = request.getParameter("secuencia_cob");
String secuencia_sol1= request.getParameter("secuencia_sol1");
String solicitud = request.getParameter("solicitud");
String cds = request.getParameter("cds");
String cobertura = request.getParameter("cobertura");
int op = 0;
String secuencia_sol2 = request.getParameter("secuencia_sol2");

if (tab == null) tab = "1";
if (cTab == null) cTab = "0";
if (mode == null) mode = "add";
if (request.getParameter("cobCDLastLineNo") != null) cobCDLastLineNo = Integer.parseInt(request.getParameter("cobCDLastLineNo"));

if (change == null) change = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change.trim().equals(""))
	{
		iCobCD.clear();
		vCobCD.clear();
		sql="select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.codigo_paciente as codigoPaciente, a.admision  as admision, a.empresa as empresa, a.solicitud as solicitud, a.secuencia_cob as secuenciaCob,a.secuencia_sol1 as secuenciaSol1, a.secuencia as secuencia, a.centro_servicio as centroServicio, a.tipo_servicio as tipoServicio, a.monto_pac as montoPac, a.tipo_val_pac as tipoValPac, a.monto_emp as montoEmp, a.tipo_val_emp as tipoValEmp, a.pase as pase, a.pase_k as paseK, coalesce(t.descripcion,c.descripcion) as descripcion  from tbl_adm_cobertura_sol2 a ,tbl_cds_centro_servicio c,tbl_cds_tipo_servicio t where a.pac_id = "+pac_id+" and a.admision = "+admision+" and a.empresa ="+empresa+" and solicitud= "+solicitud+" and secuencia_cob="+secuencia_cob+"and a.secuencia_sol1 ="+secuencia_sol1+" and a.centro_servicio = c.codigo(+) and  a.tipo_servicio= t.codigo (+)";
		//System.out.println("SQL:\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleCoberturaConvenio.class);
		cobCDLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			DetalleCoberturaConvenio cc = (DetalleCoberturaConvenio) al.get(i-1);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cc.setKey(key);
			try
			{
				iCobCD.put(cc.getKey(), cc);
				vCobCD.add(cc.getTipoServicio());
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
<script language="javascript">
document.title = 'Cobertura';

function addCobCD()
{
	setBAction('form0','+');
	parent.form0BlockButtons(true);
	form0BlockButtons(true);
	document.form0.submit();
}

function removeCobCD(k)
{
	var retVal='<%=IBIZEscapeChars.forURL("count(*)")%>';
	var msg='';

	var sec= eval('document.form0.secuencia'+k).value;
	var tipoServicio=eval('document.form0.tipoServicio'+k).value;
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_sol3','empresa=<%=empresa%> and admision=<%=admision%> and pac_id=<%=pac_id%> and solicitud=<%=solicitud%> and secuencia_cob=<%=secuencia_cob%> and secuencia_sol1=<%=secuencia_sol1%> and secuencia_sol2=\''+sec+'\'',''))msg+='\n- Cobertura solicitud 3';
	if(msg=='')
	{
		if(confirm('¿Está seguro de eliminar <%=(tipoCobertura.equalsIgnoreCase("C"))?"la Cobertura por Centro":"el Detalle de la Cobertura"%>?'))
		{
			removeItem('form0',k);
			parent.form0BlockButtons(true);
			form0BlockButtons(true);
			document.form0.submit();
		}
	}
	else CBMSG.warning('<%=(tipoCobertura.equalsIgnoreCase("C"))?"La Cobertura por Centro":"El Detalle de la Cobertura"%> no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
}

function doAction()
{

	newHeight();
	parent.form0BlockButtons(false);
<%
if (request.getParameter("type") != null)
{
%>
	if (document.form0.tipoCobertura.value == 'C') showTipoServicioList();//|| document.form0.tipoCobertura.value == 'C'

<%
}
%>
}

function showTipoServicioList()
{
	var centroServicio = parent.document.form0.centroServicio<%=index%>.value;
	var tipoServicio = parent.document.form0.codigo<%=index%>.value;

	abrir_ventana2('../common/check_tipo_servicio.jsp?fp=convenio_cobertura_solicitud&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&index=<%=index%>&pac_id=<%=pac_id%>&admision=<%=admision%>&solicitud=<%=solicitud%>&secuencia_cob=<%=secuencia_cob%>&secuencia_sol1=<%=secuencia_sol1%>&ceCDLastLineNo=<%=cobCDLastLineNo%>&fecha_nacimiento=<%=fecha_nacimiento%>&cod_pac=<%=cod_pac%>&centroServicio='+centroServicio+'&tipoServicio='+tipoServicio);
}

function doSubmit()
{
	if (document.form0.baction.value == '') document.form0.baction.value = parent.document.form0.baction.value;
	document.form0.saveOption.value = parent.document.form0.saveOption.value;
	document.form0.cobSize.value = parent.document.form0.cobSize.value;
	document.form0.cobLastLineNo.value = parent.document.form0.cobLastLineNo.value;
<%
for (int i=1; i<=iCob.size(); i++)
{
%>
	document.form0.cKey<%=i%>.value = parent.document.form0.key<%=i%>.value;
	document.form0.cRemove<%=i%>.value = parent.document.form0.remove<%=i%>.value;
	document.form0.cStatus<%=i%>.value = parent.document.form0.status<%=i%>.value;
	document.form0.cExpanded<%=i%>.value = parent.document.form0.expanded<%=i%>.value;
	document.form0.cSecuencia<%=i%>.value = parent.document.form0.secuencia<%=i%>.value;

	document.form0.cTipoCobertura<%=i%>.value = parent.document.form0.tipoCobertura<%=i%>.value;
	document.form0.cTipoServicio<%=i%>.value = parent.document.form0.tipoServicio<%=i%>.value;
	document.form0.cCentroServicio<%=i%>.value = parent.document.form0.centroServicio<%=i%>.value;
	document.form0.cCodigo<%=i%>.value = parent.document.form0.codigo<%=i%>.value;
	document.form0.cDescripcion<%=i%>.value = parent.document.form0.descripcion<%=i%>.value;
	document.form0.cMontoPac<%=i%>.value = parent.document.form0.montoPac<%=i%>.value;
	document.form0.cTipoValPac<%=i%>.value = parent.document.form0.tipoValPac<%=i%>.value;
	document.form0.cMontoEmp<%=i%>.value = parent.document.form0.montoEmp<%=i%>.value;
	document.form0.cTipoValEmp<%=i%>.value = parent.document.form0.tipoValEmp<%=i%>.value;
<%
}//cobertura
%>
	if (document.form0.baction.value == 'Guardar' && !form0Validation())
	{
		form0BlockButtons(false);
		parent.form0BlockButtons(false);
		return false;
	}
	document.form0.submit();
}

function showModal(k)
{
	var tipoServicio = eval('document.form0.tipoServicio'+k).value;
	var sec = eval('document.form0.secuencia'+k).value;
	if(!hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_sol2','empresa=<%=empresa%> and admision=<%=admision%> and pac_id=<%=pac_id%> and solicitud=<%=solicitud%> and secuencia_cob=<%=secuencia_cob%> and secuencia_sol1=<%=secuencia_sol1%> and secuencia=\''+sec+'\'','')) CBMSG.warning('Por favor guarde los cambios antes de ver los detalles!');
	else
	{
		//parent.showSelectBoxes(false);
		//showSelectBoxes(false);
		parent.showPopWin('../admision/detalle_cobertura_tipo.jsp?mode=<%=mode%>&tipoCobertura=<%=tipoCobertura%>&cobertura=<%=cobertura%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=solicitud%>&admision=<%=admision%>&secuencia_cob=<%=secuencia_cob%>&empresa=<%=empresa%>&secuencia_sol1=<%=secuencia_sol1%>&cds=<%=cds%>&secuencia_sol2='+sec+'&tipoServicio='+tipoServicio,parent.winWidth*.95,parent.winHeight*.85,null,null,'');
		//parent.window.frames[\'iDetalle0\'].showSelectBoxes(true);parent.showSelectBoxes(true);
	}
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>

<%=fb.formStart(true)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cTab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("tipoCobertura",tipoCobertura)%>
<%=fb.hidden("cobertura",cobertura)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("cobCDSize",""+iCobCD.size())%>
<%=fb.hidden("cobCDLastLineNo",""+cobCDLastLineNo)%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("cobSize","")%>
<%=fb.hidden("cobLastLineNo","")%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("secuencia_cob",secuencia_cob)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
<%=fb.hidden("cds",cds)%>

<%
al = CmnMgr.reverseRecords(iCob);
for (int i=1; i<=iCob.size(); i++)
{
	key = al.get(i - 1).toString();
%>
<%=fb.hidden("cKey"+i,"")%>
<%=fb.hidden("cRemove"+i,"")%>
<%=fb.hidden("cStatus"+i,"")%>
<%=fb.hidden("cExpanded"+i,"")%>
<%=fb.hidden("cSecuencia"+i,"")%>
<%=fb.hidden("cTipoCobertura"+i,"")%>
<%=fb.hidden("cTipoServicio"+i,"")%>
<%=fb.hidden("cCentroServicio"+i,"")%>
<%=fb.hidden("cCodigo"+i,"")%>
<%=fb.hidden("cDescripcion"+i,"")%>
<%=fb.hidden("cMontoProc"+i,"")%>
<%=fb.hidden("cPagaDifSino"+i,"")%>
<%=fb.hidden("cMontoCli"+i,"")%>
<%=fb.hidden("cTipoValCli"+i,"")%>
<%=fb.hidden("cMontoPac"+i,"")%>
<%=fb.hidden("cTipoValPac"+i,"")%>
<%=fb.hidden("cMontoEmp"+i,"")%>
<%=fb.hidden("cTipoValEmp"+i,"")%>
<%
}//cobertura
%>
<%
if (tipoCobertura.equalsIgnoreCase("C") || tipoCobertura.equalsIgnoreCase("T"))
{
%>
<tr class="TextHeader" align="center">
	<td colspan="15">C O B E R T U R A S &nbsp; P O R &nbsp; T I P O &nbsp; D E &nbsp; S E R V I C I O</td>
</tr>
<tr class="TextHeader" align="center">
	<td width="7%">C&oacute;digo</td>
	<td width="22%">Tipo de Servicio</td>
	<td width="8%">Paciente</td>
	<td width="4%">%-$</td>
	<td width="8%">Empresa</td>
	<td width="4%">%-$</td>
	<td width="1%">&nbsp;</td>
	<td width="2%"><%=fb.button("addCobCentro","+",true,false,null,null,"onClick=\"javascript:addCobCD()\"","Agregar Cobertura Centro")%></td>
</tr>
<%
	int validCobCentro = iCobCD.size();
	al = CmnMgr.reverseRecords(iCobCD);
	for (int i=1; i<=iCobCD.size(); i++)
	{
		key = al.get(i - 1).toString();
		DetalleCoberturaConvenio cc = (DetalleCoberturaConvenio) iCobCD.get(key);
		String color = "TextRow01";
		if (i % 2 == 0) color = "TextRow01";
		String displayCobCentro = "";
		if (cc.getStatus() != null && cc.getStatus().equalsIgnoreCase("D"))
		{
			displayCobCentro = " style=\"display:none\"";
			validCobCentro--;
		}
%>
<%=fb.hidden("key"+i,cc.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,cc.getStatus())%>
<%=fb.hidden("tipoServicio"+i,cc.getTipoServicio())%>
<%=fb.hidden("centroServicio"+i,cc.getCentroServicio())%>
<%=fb.hidden("tipoServicioDesc"+i,cc.getDescripcion())%>
<%=fb.hidden("secuencia"+i,cc.getSecuencia())%>

<tr class="<%=color%>" align="center"<%=displayCobCentro%>>
	<td><%=cc.getTipoServicio()%></td>
	<td align="left"><%=cc.getDescripcion()%></td>
	<td><%=fb.decBox("montoPac"+i,cc.getMontoPac(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValPac"+i,"P=%,M=$",cc.getTipoValPac(),false,false,0,"Text10",null,null)%></td>
	<td><%=fb.decBox("montoEmp"+i,cc.getMontoEmp(),false,false,false,10,11.2,"Text10",null,null)%></td>
	<td><%=fb.select("tipoValEmp"+i,"P=%,M=$",cc.getTipoValEmp(),false,false,0,"Text10",null,null)%></td>
	<td onClick="javascript:showModal(<%=i%>)" style="cursor:pointer"><img src="../images/dwn.gif" alt="Más Detalles de la Cobertura"></td>
	<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeCobCD('"+i+"')\"","Eliminar Cobertura")%></td>
</tr>
<%
	}
}
%>
<%=fb.formEnd(true)%>
</table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	int cobLastLineNo = 0;
	int defLastLineNo = 0;
	if (request.getParameter("cobLastLineNo") != null && !request.getParameter("cobLastLineNo").equals("")) cobLastLineNo = Integer.parseInt(request.getParameter("cobLastLineNo"));
	ConvenioSolBeneficio cp = new ConvenioSolBeneficio();
	cp.setEmpresa(request.getParameter("empresa"));
	cp.setSolicitud(request.getParameter("solicitud"));
	cp.setPacId(request.getParameter("pac_id"));
	cp.setCodigoPaciente(request.getParameter("cod_pac"));
	cp.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
	cp.setAdmision(request.getParameter("admision"));
	cp.setSecuenciaCob(request.getParameter("secuencia_cob"));
	cp.setSecuenciaSol1(request.getParameter("secuencia_sol1"));
	if (cTab.equals("0")) //COBERTURAS
	{
		int cobSize = 0;
		if (request.getParameter("cobSize") != null)
		{
			if (request.getParameter("cobSize").trim().equals(""))//action coming from iframe and not from parent, because iframe.doSubmit() set this value
			{
				int cobCDSize = 0;
				if (request.getParameter("cobCDSize") != null) cobCDSize = Integer.parseInt(request.getParameter("cobCDSize"));

				if (request.getParameter("tipoCobertura").equalsIgnoreCase("C"))
				{
					for (int i=1; i<=cobCDSize; i++)
					{
						DetalleCoberturaConvenio cc = new DetalleCoberturaConvenio();
						cc.setKey(request.getParameter("key"+i));
						cc.setTipoServicio(request.getParameter("tipoServicio"+i));
						cc.setDescripcion(request.getParameter("tipoServicioDesc"+i));
						cc.setMontoPac(request.getParameter("montoPac"+i));
						cc.setTipoValPac(request.getParameter("tipoValPac"+i));
						cc.setMontoEmp(request.getParameter("montoEmp"+i));
						cc.setTipoValEmp(request.getParameter("tipoValEmp"+i));
						cc.setSolicitud(request.getParameter("solicitud"));
						cc.setPacId(request.getParameter("pac_id"));
						cc.setCodigoPaciente(request.getParameter("cod_pac"));
						cc.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
						cc.setAdmision(request.getParameter("admision"));
						cc.setSecuenciaCob(request.getParameter("secuencia_cob"));
						cc.setSecuencia(request.getParameter("secuencia"+i));
						cc.setSecuenciaSol1(request.getParameter("secuencia_sol1"));
						cc.setEmpresa(request.getParameter("empresa"));
						if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
						{
							itemRemoved = cc.getKey();
							cc.setStatus("D");//D=Delete action in ConvenioMgr
							vCobCD.remove(cc.getTipoServicio());
						}
						else cc.setStatus(request.getParameter("status"+i));

						try
						{
							iCobCD.put(cc.getKey(),cc);
						}
						catch(Exception ex)
						{
							System.err.println(ex.getMessage());
						}
					}//for CoberturaCentro
				}//CoberturaCentro

				if (!itemRemoved.equals(""))
				{
					response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&empresa="+empresa+"&tipoCobertura="+tipoCobertura+"&cobertura="+cobertura+"&index="+index+"&cobCDLastLineNo="+cobCDLastLineNo+"&pac_id="+pac_id+"&cod_pac="+cod_pac+"&fecha_nacimiento="+fecha_nacimiento+"&admision="+admision+"&solicitud="+solicitud+"&secuencia_cob="+secuencia_cob+"&empresa="+empresa+"&secuencia_sol1="+secuencia_sol1+"&cds="+cds);
					return;

				}

				if (baction != null && baction.equals("+"))
				{
				response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&cTab="+cTab+"&mode="+mode+"&tipoCobertura="+tipoCobertura+"&cobertura="+cobertura+"&index="+index+"&cobCDLastLineNo="+cobCDLastLineNo+"&pac_id="+pac_id+"&cod_pac="+cod_pac+"&fecha_nacimiento="+fecha_nacimiento+"&admision="+admision+"&solicitud="+solicitud+"&secuencia_cob="+secuencia_cob+"&empresa="+empresa+"&secuencia_sol1="+secuencia_sol1+"&cds="+cds);

					return;
				}
			}
			else
			{
				cobSize = Integer.parseInt(request.getParameter("cobSize"));

				cp.getCoberturaCentroTipo().clear();

				for (int i=1; i<=cobSize; i++)
				{
					CoberturaConvenio c = new CoberturaConvenio();
					c.setKey(request.getParameter("cKey"+i));
					c.setExpanded(request.getParameter("cExpanded"+i));
					c.setSecuencia(request.getParameter("cSecuencia"+i));
					c.setCobertura(request.getParameter("cTipoCobertura"+i));
					c.setTipoCobertura(request.getParameter("cTipoCobertura"+i));
					c.setTipoServicio(request.getParameter("cTipoServicio"+i));
					c.setCentroServicio(request.getParameter("cCentroServicio"+i));
					c.setCodigo(request.getParameter("cCodigo"+i));
					c.setDescripcion(request.getParameter("cDescripcion"+i));
					c.setMontoPac(request.getParameter("cMontoPac"+i));
					c.setTipoValPac(request.getParameter("cTipoValPac"+i));
					c.setMontoEmp(request.getParameter("cMontoEmp"+i));
					c.setTipoValEmp(request.getParameter("cTipoValEmp"+i));
					c.setSolicitud(request.getParameter("solicitud"));
					c.setPacId(request.getParameter("pac_id"));
					c.setCodigoPaciente(request.getParameter("cod_pac"));
					c.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
					c.setAdmision(request.getParameter("admision"));
					c.setSecuenciaCob(request.getParameter("secuencia_cob"));
					c.setEmpresa(request.getParameter("empresa"));
					if (request.getParameter("cRemove"+i) != null && !request.getParameter("cRemove"+i).equals(""))
					{
						itemRemoved = c.getKey();
						c.setStatus("D");//D=Delete action in ConvenioMgr
						vCob.remove(c.getTipoCobertura()+((c.getCentroServicio() == null)?"":c.getCentroServicio())+((c.getTipoServicio() == null)?"":c.getTipoServicio()));
					}
					else c.setStatus(request.getParameter("cStatus"+i));

					if (!c.getStatus().equalsIgnoreCase("D") && c.getCobertura().equalsIgnoreCase(request.getParameter("tipoCobertura")) && c.getSecuencia().equalsIgnoreCase(request.getParameter("cobertura")))
					{
						int cobCDSize = 0;
						if (request.getParameter("cobCDSize") != null) cobCDSize = Integer.parseInt(request.getParameter("cobCDSize"));

						if (c.getCobertura().equalsIgnoreCase("C") || c.getCobertura().equalsIgnoreCase("T"))
						{
							for (int j=1; j<=cobCDSize; j++)
							{
								DetalleCoberturaConvenio cc = new DetalleCoberturaConvenio();

								cc.setKey(request.getParameter("key"+j));
								cc.setTipoServicio(request.getParameter("tipoServicio"+j));
								cc.setDescripcion(request.getParameter("tipoServicioDesc"+j));
								cc.setCentroServicio(request.getParameter("cds"));
								cc.setMontoPac(request.getParameter("montoPac"+j));
								cc.setTipoValPac(request.getParameter("tipoValPac"+j));
								cc.setMontoEmp(request.getParameter("montoEmp"+j));
								cc.setTipoValEmp(request.getParameter("tipoValEmp"+j));
								cc.setStatus(request.getParameter("status"+j));
								cc.setSecuencia(request.getParameter("secuencia"+j));
								cc.setSolicitud(request.getParameter("solicitud"));
								cc.setPacId(request.getParameter("pac_id"));
								cc.setCodigoPaciente(request.getParameter("cod_pac"));
								cc.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
								cc.setAdmision(request.getParameter("admision"));
								cc.setSecuenciaCob(request.getParameter("secuencia_cob"));
								cc.setEmpresa(request.getParameter("empresa"));
								cc.setSecuenciaSol1(request.getParameter("secuencia_sol1"));
								try
								{
									iCobCD.put(cc.getKey(),cc);
									c.addCoberturaCDet(cc);
								}
								catch(Exception ex)
								{
									System.err.println(ex.getMessage());
								}
							}//for CoberturaCentro
						}//CoberturaCentro

					}//detail Cobertura
					try
					{
						iCob.put(c.getKey(),c);
						cp.addCoberturaCentroTipo(c);
						key = c.getTipoCobertura()+((c.getCentroServicio() == null)?"":c.getCentroServicio())+((c.getTipoServicio() == null)?"":c.getTipoServicio());
						if (!c.getStatus().equalsIgnoreCase("D") && !key.equalsIgnoreCase("C") && !key.equalsIgnoreCase("T") && !vCob.contains(key))
							vCob.add(key);
					}
					catch(Exception ex)
					{
						System.err.println(ex.getMessage());
					}
				}//for Cobertura
			}//cobSize != ""
		}//cobSize != null

		if (baction != null && baction.equals("+"))//agregar cobertura sol 1
		{
			CoberturaConvenio c = new CoberturaConvenio();

			cobLastLineNo++;
			if (cobLastLineNo < 10) key = "00" + cobLastLineNo;
			else if (cobLastLineNo < 100) key = "0" + cobLastLineNo;
			else key = "" + cobLastLineNo;
			c.setKey(key);

			c.setSecuencia("0");
			c.setStatus("");
			try
			{
				iCob.put(c.getKey(),c);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}

		if (baction != null && baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SBMgr.saveSol1(cp);
			ConMgr.clearAppCtx(null);

		}

	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (baction != null && baction.equals("+"))
	{
%>
	parent.location = '../admision/detalle_cobertura_convenio.jsp?change=1&type=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&index=<%=index%>&cobLastLineNo=<%=cobLastLineNo%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&admision=<%=admision%>&solicitud=<%=solicitud%>&secuencia_cob=<%=secuencia_cob%>&empresa=<%=empresa%>&secuencia_sol1=<%=secuencia_sol1%>&cds=<%=cds%>&ceCDLastLineNo=<%=cobCDLastLineNo%>';
<%
	}
	else if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{

%>
	parent.document.form0.errCode.value='<%=SBMgr.getErrCode()%>';
	parent.document.form0.errMsg.value='<%=IBIZEscapeChars.forHTMLTag(SBMgr.getErrMsg())%>';
	parent.document.form0.tipoCE.value='<%=tipoCobertura%>';
	parent.document.form0.ce.value='<%=cobertura%>';
	parent.document.form0.index.value='<%=index%>';
	parent.document.form0.empresa.value='<%=empresa%>';
	parent.document.form0.cds.value='<%=cds%>';
	parent.document.form0.secuencia_sol1.value='<%=secuencia_sol1%>';
	parent.document.form0.submit();
<%
	}
	else
	{
%>
	parent.location = '../admision/detalle_cobertura_convenio.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&tipoCE=<%=tipoCobertura%>&ce=<%=cobertura%>&index=<%=index%>&cobLastLineNo=<%=request.getParameter("cobLastLineNo")%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&admision=<%=admision%>&solicitud=<%=solicitud%>&secuencia_cob=<%=secuencia_cob%>&empresa=<%=empresa%>&secuencia_sol1=<%=secuencia_sol1%>&cds=<%=cds%>&ceCDLastLineNo=<%=request.getParameter("cobCDLastLineNo")%>';
<%
	}
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>