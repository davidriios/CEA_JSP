<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.HojaMedicamento"%>
<%@ page import="issi.expediente.HojaMedicamentoDet"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
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
var noNewHeight = true;
document.title = 'Hoja de Medicamentos- '+document.title;
function doAction(){<%if(request.getParameter("type") != null){%>abrir_ventana1('../common/check_medicamentos.jsp?fp=med&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&lastLineNo=<%=lastLineNo%>&mode=<%=mode%>&modeSec=<%=modeSec%>&from=exp3&cds=<%=cds%>');<%}%>}
function doSubmit(){document.form0.baction.value = parent.document.form0.baction.value;document.form0.saveOption.value = parent.document.form0.saveOption.value;document.form0.dob.value = parent.document.form0.dob.value;document.form0.codPac.value = parent.document.form0.codPac.value;document.form0.fecha.value = parent.document.form0.fecha.value;document.form0.hora.value = parent.document.form0.hora.value;if (document.form0.baction.value == 'Guardar' && !form0Validation()){form0BlockButtons(false);parent.form0BlockButtons(false);return false;}document.form0.submit();}
function showFrecuencia(k){abrir_ventana1('../expediente/sel_frecuencia.jsp?id=1&index='+k);}
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
</head>
<body class="body-form" rightmargin="0" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<tr class="bg-headtabla">
			 <th width="35%"><cellbytelabel id="1">Medicamento</cellbytelabel></th>
			 <th width="15%"><cellbytelabel id="2">V&iacute;a</cellbytelabel></th>
			 <th width="25%"><cellbytelabel id="3">Frecuencia</cellbytelabel></th>
			 <th width="20%"><cellbytelabel id="3">Dosis</cellbytelabel></th>
			 <th width="5%"><%=fb.submit("agregar","+",false,viewMode,"btn btn-success btn-xs",null,"")%></th>
		</tr>

<%
al = CmnMgr.reverseRecords(HashMed);
for (int i=1; i<=HashMed.size(); i++)
{
	key = al.get(i - 1).toString();
	HojaMedicamentoDet det = (HojaMedicamentoDet) HashMed.get(key);
   String displayNote = "";
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("codigo"+i,det.getCodigo())%>
		<%=fb.hidden("hora"+i,det.getHora())%>
		<%=fb.hidden("viaAdm"+i,det.getVia())%>
		<%=fb.hidden("remove"+i,"")%>

		<tr>
            <td><%=fb.textBox("medicamento"+i,det.getMedicamento(),true,false,(!det.getCodigo().trim().equals("0")),40,"form-control input-sm",null,null)%></td>
            <td><%=fb.select("via"+i,alViaAd,det.getVia(),false,viewMode||(det.getCodigo() != null && !det.getCodigo().trim().equals("") && !det.getCodigo().trim().equals("0")),0,"",null,null,"","")%></td>
            <td><%=fb.textBox("frecuencia"+i,det.getFrecuencia(),false,false,viewMode||(det.getCodigo() != null && !det.getCodigo().trim().equals("") && !det.getCodigo().trim().equals("0")),25,"form-control input-sm",null,null)%></td>
			<td><%=fb.textBox("dosisDesc"+i,det.getDosisDesc(),false,false,viewMode||(det.getCodigo() != null && !det.getCodigo().trim().equals("") && !det.getCodigo().trim().equals("0")),20,"form-control input-sm",null,null)%></td>
            <td><%=fb.submit("rem"+i,"x",true,viewMode||(det.getCodigo() != null && !det.getCodigo().trim().equals("") && !det.getCodigo().trim().equals("0")),"btn btn-xs btn-primary",null,"onclick=\"removeItem(this.form.name,"+i+");__submitForm(this.form, this.value)\"")%></td>
		</tr>
        <tr>
            <td colspan="5">
                <cellbytelabel id="4">Observaciones</cellbytelabel>&nbsp;<%=fb.textarea("observacion"+i,det.getObservacion(),false,false,viewMode||(det.getCodigo() != null && !det.getCodigo().trim().equals("") && !det.getCodigo().trim().equals("0")),50,0,2000,"form-control input-sm","width:100%","")%>
             </td>
        </tr>

<%
}
%>
</table>
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
	int size = Integer.parseInt(request.getParameter("size"));
	lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
    
    System.out.println("....................................................................... baction = "+baction);

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
		hDet.setHora(request.getParameter("hora"+i));
		hDet.setMedicamento(request.getParameter("medicamento"+i));
		hDet.setDosis("0"+i);
		hDet.setDosisDesc(request.getParameter("dosisDesc"+i));
		hDet.setFrecuencia(request.getParameter("frecuencia"+i));
		hDet.setObservacion(request.getParameter("observacion"+i));
		if (hDet.getCodigo() != null && !hDet.getCodigo().trim().equals("") && !hDet.getCodigo().trim().equals("0"))
		hDet.setVia(request.getParameter("viaAdm"+i));
		else hDet.setVia(request.getParameter("via"+i));

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

	if (!ItemRemoved.equals("")){
		vMed.remove(med);
		HashMed.remove(ItemRemoved);
		response.sendRedirect("../expediente3.0/exp_hoja_medicamento_det.jsp?seccion="+seccion+"&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&cds="+cds+"&lastLineNo="+lastLineNo+"&change=1");
		return;
	}

	if (baction != null && baction.trim().equalsIgnoreCase("+")){
		response.sendRedirect("../expediente3.0/exp_hoja_medicamento_det.jsp?seccion="+seccion+"&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&cds="+cds+"&lastLineNo="+lastLineNo+"&change=1&type=1");
		return;
	}
    
	if (baction != null && baction.trim().equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) HMMgr.add(hMed);
		else if (modeSec.equalsIgnoreCase("edit")) HMMgr.update(hMed);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
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

