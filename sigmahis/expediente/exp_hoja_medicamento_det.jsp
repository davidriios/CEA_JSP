<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.HojaMedicamento"%>
<%@ page import="issi.expediente.HojaMedicamentoDet"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="HashMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMed" scope="session" class="java.util.Vector" />
<jsp:useBean id="HMMgr" scope="page" class="issi.expediente.HojaMedicamentoMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
SAL310111 Expediente Enfermeria
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
HMMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
ArrayList alViaAd = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
StringBuffer sbSql = new StringBuffer();
boolean viewMode = false;
String sql = "";
String appendFilter = "";
String seccion = request.getParameter("seccion");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");

int lastLineNo = 0;
String key = "";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
		alViaAd = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion||' - '||codigo as optLabelColumn, codigo as optTitleColumn from tbl_sal_via_admin where tipo_liquido='M' order by codigo",CommonDataObject.class);
		sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad   from dual");
CommonDataObject cdoP = (CommonDataObject) SQLMgr.getData(sbSql.toString());
if (cdoP == null) cdoP = new CommonDataObject();

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Hoja de Medicamentos- '+document.title;
function doAction(){newHeight();parent.newHeight();<%if(request.getParameter("type") != null){%>abrir_ventana1('../common/check_medicamentos.jsp?fp=med&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&lastLineNo=<%=lastLineNo%>&mode=<%=mode%>&modeSec=<%=modeSec%>');<%}%>}
function doSubmit(){document.form0.baction.value = parent.document.form0.baction.value;document.form0.saveOption.value = parent.document.form0.saveOption.value;document.form0.dob.value = parent.document.form0.dob.value;document.form0.codPac.value = parent.document.form0.codPac.value;document.form0.fecha.value = parent.document.form0.fecha.value;document.form0.hora.value = parent.document.form0.hora.value;if (document.form0.baction.value == 'Guardar' && !form0Validation()){form0BlockButtons(false);parent.form0BlockButtons(false);return false;}document.form0.submit();}
function showFrecuencia(k){abrir_ventana1('../expediente/sel_frecuencia.jsp?id=1&index='+k);}

$(function(){
  $(".control-launcher").tooltip({
	content: function () {
	  var $i = $(this).data("i");
	  var $title = $($(this).prop('title'));
	  var $content = $("#controlCont"+$i).val();
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	},
	position: { my: "left+15 center", at: "right center" }
  });
});
</script>
<style type="text/css">
.ui-tooltip {
    z-index: 10000 !important;
}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("size",""+HashMed.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("hora","")%>
<%=fb.hidden("cds",""+cds)%>
<%fb.appendJsValidation("if(document.form0.baction.value!='Guardar')return true;");%>
<%fb.appendJsValidation("if("+HashMed.size()+"==0){alert('Por favor introduzca por lo menos un Registro!');error++;}");%>
<%//fb.appendJsValidation("if(!isValidDetailsDateTime())error++;");%>

		<tr align="center" class="TextHeader">
			 <td width="40%"><cellbytelabel id="1">Medicamento</cellbytelabel></td>
			<!-- <td width="6%">Dosis</td>-->
			<%if(cdoP.getColValue("addCantidad").trim().equals("S")){%> <td width="6%">Cantidad</td><%}%>
			 <td width="15%"><cellbytelabel id="2">V&iacute;a</cellbytelabel></td>
			 <td width="30%"><cellbytelabel id="3">Frecuencia</cellbytelabel></td>
			<td width="5%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Medicamento")%></td>
		</tr>

<%
al = CmnMgr.reverseRecords(HashMed);
for (int i=1; i<=HashMed.size(); i++)
{
	key = al.get(i - 1).toString();
	HojaMedicamentoDet det = (HojaMedicamentoDet) HashMed.get(key);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
    String displayNote = "";
	String _dosisData = det.getDosisDesc();
	String dosisDesc = "";
	String control = "";
	String[] dosisData = {};
	if (_dosisData != null && !_dosisData.trim().equals("")) {
		dosisData = _dosisData.split("@");
		try {
			dosisDesc = dosisData[0];
			control = dosisData[1];
		} catch(Exception e) {}
	}
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("codigo"+i,det.getCodigo())%>
		<%=fb.hidden("hora"+i,det.getHora())%>
		<%=fb.hidden("viaAdm"+i,det.getVia())%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("controlCont"+i,"<label class='controlCont' style='font-size:11px'>"+(control==null?"":control)+"</label>")%>

		<tr class="<%=color%>" align="center">
				<td><%=fb.textBox("medicamento"+i,det.getMedicamento(),true,false,(!det.getCodigo().trim().equals("0")),40,"Text10",null,null)%>	
								
				<img src="../images/info.png" width="24px" height="24px" class="control-launcher" title="" data-i="<%=i%>" style="vertical-align:middle">
				
				</td>
<!--				<td><%//=fb.textBox("dosis"+i,det.getDosis(),false,false,viewMode,10,"Text10",null,null)%>	</td>-->
				<%if(cdoP.getColValue("addCantidad").trim().equals("S")){%><td>Cantidad: <%=fb.intBox("cantidad"+i,det.getCantidad(),true,false,viewMode,3,3)%></td><%}else{%>
			<%=fb.hidden("cantidad"+i,"")%><%}%>
				<td><%=fb.select("via"+i,alViaAd,det.getVia(),false,viewMode,0,"Text10",null,null,"","")%>
					<%//=fb.select("via"+i,"O=ORAL, P=PARENTERAL, E=ENTERAL, I=INYECTABLE, T=TOPICO",det.getVia(),false,(!det.getCodigo().trim().equals("0")),0,"Text10",null,null,"","")%>
				</td>
				<td><%=fb.textBox("frecuencia"+i,det.getFrecuencia(),false,false,false,40,"Text10",null,null)%>
				<td rowspan="2"><%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
			</tr>
			<tr class="<%=color%>" >
			<td colspan="4"><%//=fb.textBox("frecuencia"+i,det.getFrecuencia(),false,false,true,15,"Text10",null,null)%>
				<%//=fb.textBox("descFrecuencia"+i,det.getDescFrecuencia(),false,false,true,30,"Text10",null,null)%>
				<%//=fb.button("addFrecuencia"+i,"...",true,false,null,null,"onClick=\"javascript:showFrecuencia("+i+")\"")%>
			<cellbytelabel id="4">Observaciones</cellbytelabel>&nbsp;<%=fb.textarea("observacion"+i,det.getObservacion(),false,false,viewMode,50,2,2000,null,"width:90%","")%></td>
			</tr>

<%
}
%>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

	HojaMedicamento hMed= new HojaMedicamento();
	hMed.setPacId(pacId);
	hMed.setSecuencia(noAdmision);
	hMed.setFecNacimiento(request.getParameter("dob"));
	hMed.setCodPaciente(request.getParameter("codPac"));
	hMed.setFecha(request.getParameter("fecha"));
	hMed.setHora(request.getParameter("hora"));
	hMed.setUsuarioCreacion((String) session.getAttribute("_userName"));
	hMed.setUsuarioModif((String) session.getAttribute("_userName"));

	String ItemRemoved = "",med="";
	for (int i=1; i<=size; i++)
	{
		HojaMedicamentoDet hDet = new HojaMedicamentoDet();

		hDet.setCodigo(request.getParameter("codigo"+i));
		//hDet.setFecha(request.getParameter("fecha"));
		hDet.setHora(request.getParameter("hora"+i));
		hDet.setMedicamento(request.getParameter("medicamento"+i));
	//	hDet.setDosis(request.getParameter("dosis"+i));
		hDet.setDosis("0"+i);		
		hDet.setCantidad(request.getParameter("cantidad"+i));

		hDet.setFrecuencia(request.getParameter("frecuencia"+i));
		//hDet.setDescFrecuencia(request.getParameter("descFrecuencia"+i));
		hDet.setObservacion(request.getParameter("observacion"+i));
		if (hDet.getCodigo() != null && !hDet.getCodigo().trim().equals("") && !hDet.getCodigo().trim().equals("0"))
		hDet.setVia(request.getParameter("viaAdm"+i));
		else hDet.setVia(request.getParameter("via"+i));

		////System.out.println("via adm ===  "+hDet.getVia());
		hDet.setKey(request.getParameter("key"+i));
		key = request.getParameter("key"+i);


		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			ItemRemoved = key;
			med = hDet.getMedicamento();
		}
		else
		{
			try
			{
				HashMed.put(key, hDet);
				hMed.addDetalle(hDet);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for

	if (!ItemRemoved.equals(""))
	{
		vMed.remove(med);
		HashMed.remove(ItemRemoved);
		response.sendRedirect("../expediente/exp_hoja_medicamento_det.jsp?seccion="+seccion+"&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&cds="+cds+"&lastLineNo="+lastLineNo+"&change=1");
		return;
	}

	if (baction != null && baction.trim().equalsIgnoreCase("+"))
	{
		/*HojaMedicamentoDet hmd = new HojaMedicamentoDet();

		hmd.setCodigo("0");

		String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
		hmd.setHora(cDate.substring(11));

		lastLineNo++;
		if (lastLineNo < 10) key = "00" + lastLineNo;
		else if (lastLineNo < 100) key = "0" + lastLineNo;
		else key = "" + lastLineNo;
		hmd.setKey(""+lastLineNo);

		try
		{
			HashMed.put(key, hmd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
*/
		response.sendRedirect("../expediente/exp_hoja_medicamento_det.jsp?seccion="+seccion+"&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&cds="+cds+"&lastLineNo="+lastLineNo+"&change=1&type=1");
		return;
	}

	if (baction != null && baction.trim().equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) HMMgr.add(hMed);
		else if (modeSec.equalsIgnoreCase("edit")) HMMgr.update(hMed);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (HMMgr.getErrCode().equals("1")){%>

	parent.document.form0.errCode.value='<%=HMMgr.getErrCode()%>';
	parent.document.form0.errMsg.value='<%=IBIZEscapeChars.forHTMLTag(HMMgr.getErrMsg())%>';
	parent.document.form0.submit();
	<%} else throw new Exception(HMMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>

