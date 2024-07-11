<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.Comprobante"%>
<%@ page import="issi.contabilidad.CompDetails"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CompMgr" scope="page" class="issi.contabilidad.ComprobanteMgr" />
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCta" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CompMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Comprobante CompDet = new Comprobante();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String anio = request.getParameter("anio");
String no = request.getParameter("no");
String change = request.getParameter("change");
String clase = request.getParameter("clase");
String tipo = request.getParameter("tipo");
int lastLineNo = 0;

if (mode == null) mode = "app";

if (fg == null) throw new Exception("El Tipo de Comprobante no es válido. Por favor intente nuevamente!");
if (anio == null || no == null) throw new Exception("El Comprobante no es válido. Por favor intente nuevamente!");
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("app") || mode.equalsIgnoreCase("del") || mode.equalsIgnoreCase("pase"))
	{
		if (change == null)
		{
			iCta.clear();
			vCta.clear();

			sql = "select ea_ano eaano, '0' consecutivo, compania, mes, '26' as clasecomprob, descripcion, total_cr totalcr, total_db totaldb, n_doc ndoc, status, to_char(fecha_comp,'dd/mm/yyyy') fechacomp, comp_resum compresum, to_char(fecha_comp,'dd/mm/yyyy') fechaCreacion, to_char(sysdate,'dd/mm/yyyy') consecutivocia from tbl_pla_pre_encab_comprob where compania="+(String) session.getAttribute("_companyId")+" and clase_comprob="+clase+" and ea_ano="+anio+" and consecutivo="+no;
			System.out.println("Encab=\n"+sql);
			CompDet = (Comprobante) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Comprobante.class);

			sql = "select lpad(rownum,3,'0') as key, ano, consecutivo, compania, renglon, ano_cta anocta, cta1, cta2, cta3, cta4, cta5, cta6, tipo_mov tipomov, valor, comentario, 0 as refType, renglon as refId, 'ASIENTO DE PLANILLA' as refDesc from tbl_pla_pre_detalle_comprob where ano="+anio+" and consecutivo="+no+" and compania="+(String) session.getAttribute("_companyId")+"";
			System.out.println("Det=\n"+sql);
			CompDet.setCompDetail(sbb.getBeanList(ConMgr.getConnection(), sql, CompDetails.class));

			CompDet.setFechaSistema(CmnMgr.getCurrentDate("dd/mm/yyyy"));
			lastLineNo = CompDet.getCompDetail().size();
			for (int i=0; i<CompDet.getCompDetail().size(); i++)
			{
				CompDetails cta = (CompDetails) CompDet.getCompDetail().get(i);

				try
				{
					iCta.put(cta.getKey(), cta);
					vCta.add(cta.getCta1()+"-"+cta.getCta2()+"-"+cta.getCta3()+"-"+cta.getCta4()+"-"+cta.getCta5()+"-"+cta.getCta6());
				}
				catch (Exception e)
				{
					System.out.println("Unable to addget cta "+key);
				}
			}
		}
		if (mode.equalsIgnoreCase("pase")) mode = "add";
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Comprobante <%=(fg.equals("CD"))?"Diario":"Histórico"%> - "+document.title;

function doSubmit(baction)
{
	document.form1.baction.value = baction;
	window.frames['itemFrame'].doSubmit();
}
</script>
</head>
<%if(mode.equals("app")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - APROBACION DE COMPROBANTE DIARIO"></jsp:param>
</jsp:include>
<%} else if(mode.equals("del")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - DESAPROBACION DE COMPROBANTE DIARIO"></jsp:param>
</jsp:include>
<%} else if(mode.equals("pase")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - PASE A CONTABILIDAD DE COMPROBANTE DIARIO"></jsp:param>
</jsp:include>
<%} %>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode","add")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("no",no)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+iCta.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
		<tr class="TextRow02">
			<td colspan="10">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">A&ntilde;o</td>
			<td><%=fb.intBox("ea_anio",CompDet.getEaAno(),true,false,true,5,null,null,null)%></td>
			<td align="right">Mes</td>
			<td><%=fb.intBox("mes",CompDet.getMes(),true,false,true,5)%></td>
			<td align="right">Consecutivo</td>
			<td><%=fb.intBox("consecutivo",CompDet.getConsecutivo(),false,false,true,5)%></td>
			<td align="right">Fecha Creaci&oacute;n</td>
			<td><%=fb.textBox("fecha",CompDet.getFechaCreacion(),false,false,( mode.trim().equals("edit")),10)%></td>
			<td align="right">Fecha Sistema</td>
			<td><%=fb.textBox("fechaSistema",CompDet.getFechaSistema(),false,false,true,10)%></td>	
		</tr>
		<tr class="TextRow01">
			<td align="right">Clase</td>
			<td colspan="7">
				<%=fb.hidden("clase_comprob",CompDet.getClaseComprob())%>
				<%=fb.select(ConMgr.getConnection(), "select codigo_comprob, descripcion from tbl_con_clases_comprob where codigo_comprob = 26", "clase", CompDet.getClaseComprob(),false,true,0)%>
			</td>
			<td align="right">Estado</td>
			<td><%=fb.select("status",((mode.equals("app"))?"AP=Aprobar":"DE=Desaprobar")+",PE=Pendiente",CompDet.getStatus())%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Descripci&oacute;n</td>
			<td colspan="7"><%=fb.textBox("descripcion",CompDet.getDescripcion(),true,false,true,90)%></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">No. Comprobante</td>
			<td><%=fb.textBox("consecutivoCia",CompDet.getConsecutivoCia(),false,false,false,10)%></td>
			<td colspan="6">&nbsp;</td>
			<td align="right">D&eacute;bito</td>
				<td><%=fb.decBox("sumDebito",CompDet.getTotalDb(),false,false,true,10)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Doc. Fuente</td>
			<td><%=fb.textBox("n_doc",CompDet.getNDoc(),false,false,false,10)%></td>
			<td colspan="6">&nbsp;</td>
			<td align="right">Cr&eacute;dito</td>
			<td><%=fb.decBox("sumCredito",CompDet.getTotalCr(),false,false,true,10)%></td>
		</tr>
		<tr>
			<td colspan="10">
				<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../rhplanilla/reg_app_comp_diario_det.jsp?mode=add&fg=<%=fg%>&<%=anio%>&no=<%=no%>"></iframe>
			</td>					
		</tr>		
		<tr class="TextRow01">
			<td colspan="8" align="right">Totales del Detalle</td>
		    <td align="right">DB <%=fb.decBox("totalDb",CompDet.getTotalDb(),false,false,true,10,null,null,"")%></td>
			<td align="right">CR <%=fb.decBox("totalCr",CompDet.getTotalCr(),false,false,true,10,null,null,"")%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="10" align="right">
				Opciones de Guardar: 
				<!--<%=fb.radio("saveOption","N")%>Crear Otro -->
				<!--<%=fb.radio("saveOption","O")%>Mantener Abierto -->
				<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
				<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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

	if (!request.getParameter("errCode").trim().equals(""))
	{
		CompMgr.setErrCode(request.getParameter("errCode"));
		CompMgr.setErrMsg(request.getParameter("errMsg"));
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (CompMgr.getErrCode().equals("1"))
{
%>
  alert('<%=CompMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_mg_comp_diario.jsp"))
	{
%>
  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_mg_comp_diario.jsp")%>?fg=<%=fg%>';
<%
	}
	else
	{
%>
  window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_mg_comp_diario.jsp?fg=<%=fg%>';
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
  window.close();
<%
  }
} else throw new Exception(CompMgr.getErrMsg());
%>
}

function addMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>';
}

function editMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>