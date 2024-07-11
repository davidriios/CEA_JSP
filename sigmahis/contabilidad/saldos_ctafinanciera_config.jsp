<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.SaldoCta"%>
<%@ page import="issi.contabilidad.DetalleSaldo"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="SaldoMgr" scope="page" class="issi.contabilidad.SaldoCtaMgr" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
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
SaldoMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String sql = "";
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
String anio = request.getParameter("anio");
String mode = request.getParameter("mode");
String key = "";
int lastLineNo = 0;
SaldoCta sald = new SaldoCta();
if(mode == null) mode ="";
boolean viewMode = false;
if(mode.equals("view")) viewMode=true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (anio == null) throw new Exception("El Año no es válido. Por favor intente nuevamente!");		  
		  
  sql = "SELECT a.ano as anio, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as cuenta, a.monto_debito as montoDb, a.monto_credito as montoCr, a.saldo_actual as saldoAct, a.saldo_inicial as saldoIni, a.status_cta as status, a.saldo_anterior as saldoAnte FROM tbl_con_plan_cuentas a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.compania=b.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.ano="+anio+" and a.cta1="+cta1+" and a.cta2="+cta2+" and a.cta3="+cta3+" and a.cta4="+cta4+" and a.cta5="+cta5+" and a.cta6="+cta6;
  sald = (SaldoCta) sbb.getSingleRowBean(ConMgr.getConnection(),sql, SaldoCta.class);
			
  sql = "SELECT a.ea_ano as anio, a.mes, a.cat_cta1 as cta1, a.cat_cta2 as cta2, a.cat_cta3 as cta3, a.cat_cta4 as cta4, a.cat_cta5 as cta5, a.cat_cta6 as cta6, a.monto_db as montoDb, a.monto_cr as montoCr, a.monto_i as montoIni,(nvl(a.monto_i,0)+nvl(a.monto_db,0)-nvl(a.monto_cr,0)) as montoFin, a.status_inic as statusIni, a.status_final as statusFin FROM tbl_con_mov_mensual_cta a WHERE a.pc_compania="+(String) session.getAttribute("_companyId")+" and a.ea_ano="+anio+" and a.cat_cta1='"+cta1+"' and a.cat_cta2='"+cta2+"' and a.cat_cta3='"+cta3+"' and a.cat_cta4='"+cta4+"' and a.cat_cta5='"+cta5+"' and a.cat_cta6='"+cta6+"'";
	System.out.println(sql);
  al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleSaldo.class);                   
	
  HashDet.clear(); 
	
  for (int i = 1; i <= al.size(); i++)
  {
	if (i < 10) key = "00" + i;
	else if (i < 100) key = "0" + i;
	else key = "" + i;

	HashDet.put(key, al.get(i-1));
	lastLineNo = i;
  }  	  			
%>
<html>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script> 
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function adjustIFrameSize (iframeWindow) 
{
	if (iframeWindow.document.height) {
	var iframeElement = document.getElementById (iframeWindow.name);
	iframeElement.style.height = (parseInt(iframeWindow.document.height,10) + 16) + 'px';
//            iframeElement.style.width = iframeWindow.document.width + 'px';
	}
	else if (document.all) {
	var iframeElement = document.all[iframeWindow.name];
	if (iframeWindow.document.compatMode &&
	iframeWindow.document.compatMode != 'BackCompat')
	{
	iframeElement.style.height = iframeWindow.document.documentElement.scrollHeight + 5 + 'px';
	}
	else {
	iframeElement.style.height = iframeWindow.document.body.scrollHeight + 5 + 'px';
	}
	}
}

document.title=" Saldo Ctas Edición - "+document.title;

function addCuenta()
{
  abrir_ventana1('../contabilidad/ctabancaria_catalogo_list.jsp?id=20');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - SALDOS DE CTAS FINANCIERAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">   
<tr>  
	<td class="TableBorder">   

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center"> 
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
	<tr>    
		<td>   
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TPrincipal" align="left" width="100%" onClick="javascript:verocultar(panel0)" onMouseover="bcolor('#5c7188','TPrincipal');" onMouseout="bcolor('#8f9ba9','TPrincipal');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%" >&nbsp;SALDOS DE CTAS. FINANCIERA</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>  	
					<div id="panel0" style="visibility:visible;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">										
							<tr class="TextRow01">
								<td width="15%">A&ntilde;o</td>
								<td width="32%"><%=fb.textBox("anio",anio,true,false,true,10)%></td>
								<td width="18%">Status de Ctas.</td> 
								<td width="35%"><%=fb.select("status","DB=Débito,CR=Crédito",sald.getStatus())%></td>			 				
							</tr>
							<tr class="TextRow01">
							    <td>Cta. Financiera</td> 
								<td colspan="3"><%=fb.textBox("cta1",sald.getCta1(),true,false,true,5)%><%=fb.textBox("cta2",sald.getCta2(),true,false,true,5)%><%=fb.textBox("cta3",sald.getCta3(),true,false,true,5)%><%=fb.textBox("cta4",sald.getCta4(),true,false,true,5)%><%=fb.textBox("cta5",sald.getCta5(),true,false,true,5)%><%=fb.textBox("cta6",sald.getCta6(),true,false,true,5)%><%=fb.textBox("cuenta",sald.getCuenta(),true,false,true,60)%></td>
							</tr>	
							<tr class="TextRow01"> 
							    <td>Saldo Inicial</td>
								<td><%=fb.decBox("saldoIni",sald.getSaldoIni(),true,false,viewMode,42)%></td>	
								<td>Recibe Mov.</td> 
								<td><%=fb.textBox("recibeMov",sald.getFechaMov(),false,true,viewMode,44)%></td>							
							</tr>
							<tr class="TextRow01"> 
							    <td>Monto D&eacute;bito</td> 
								<td><%=fb.decBox("montoDb",sald.getMontoDb(),true,false,viewMode,42)%></td>
								<td>Monto Cr&eacute;dito</td> 
								<td><%=fb.decBox("montoCr",sald.getMontoCr(),true,false,viewMode,44)%></td>
							</tr>	
							<tr class="TextRow01"> 
							    <td>Saldo Anterior</td> 
								<td><%=fb.decBox("saldoAnte",sald.getSaldoAnte(),true,false,viewMode,42)%></td>
								<td>Saldo Actual</td> 
								<td><%=fb.decBox("saldoAct",sald.getSaldoAct(),true,false,viewMode,44)%></td>
							</tr>								
						</table>
					</div>
					</td>     
				</tr>   
			</table>			
		</td>  
	</tr>  
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TOtros" align="left" width="100%" onClick="javascript:verocultar(panel1)" onMouseover="bcolor('#5c7188','TOtros');" onMouseout="bcolor('#8f9ba9','TOtros');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;DETALLE DE CTA. FINANCIERA</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>				
				<tr>
					<td>
					    <div id="panel1" style="inline:display;">
					    <iframe name="detalle" frameborder="0" style="width:100%; height:90px;" src="../contabilidad/detallesaldos_config.jsp?lastLineNo=<%=lastLineNo%>&mode=<%=mode%>" id="iddetalle"></iframe>
						</div>
					</td>
				</tr>
			</table>			
		</td>
	</tr>
	<tr class="TextRow01">
		<td align="right">
			<%//=fb.button("save","Guardar",true,viewMode,null, null, "onClick=\"window.frames['detalle'].doSubmit()\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
<%=fb.formEnd(true)%>
</table>				
<%@ include file="../common/footer.jsp"%>
</div>
	
<!--STYLE DW-->
<!--*************************************************************************************************************-->	
	</td>
	<td>&nbsp;</td>
</tr> 		
</table>
</body>
</html>
<%
}//GET
else
{
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/saldos_ctafinanciera_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/saldos_ctafinanciera_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/saldos_ctafinanciera_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(errMsg);
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