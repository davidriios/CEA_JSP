<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.DocumentTransaction"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String blockId = request.getParameter("blockId");

if (blockId == null) throw new Exception("El Bloque no es válido. Por favor intente nuevamente!");

if(request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select x.trans_block_id as transBlockId, to_char(x.trans_date,'dd/mm/yyyy') as transDate, x.trans_type as transType, x.compania, x.doc_type as docType, x.doc_id as docId, x.doc_no as docNo, to_char(x.doc_date,'dd/mm/yyyy') as docDate, x.doc_amt as docAmt, x.cta1, x.cta2, x.cta3, x.cta4, x.cta5, x.cta6, x.debit, x.credit, x.cta1||'-'||x.cta2||'-'||x.cta3||'-'||x.cta4||'-'||x.cta5||'-'||x.cta6 as ctaNo, y.descripcion as ctaDesc from tbl_con_accdoc_trans x, tbl_con_catalogo_gral y where x.trans_block_id="+blockId+" and x.compania=y.compania and x.cta1=y.cta1 and x.cta2=y.cta2 and x.cta3=y.cta3 and x.cta4=y.cta4 and x.cta5=y.cta5 and x.cta6=y.cta6 order by debit desc, credit";
	System.out.println("SQL=\n"+sql);
  al = sbb.getBeanList(ConMgr.getConnection(),sql,DocumentTransaction.class);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Contabilidad - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="CONTABILIDAD - TRANSACCIONES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;</td>
  </tr> 
  <tr>
    <td>
      <table width="100%" cellpadding="1">
        <tr class="TextRow07 Text10Bold">   
          <td width="50%">No. Bloque: <%=blockId%></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td align="right">&nbsp;
<%
//if (SecMgr.checkAccess(session.getId(),"0"))
//{
%>
      <!--<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>-->
<%
//}
%>
    </td>
  </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0" class="TableBorder">
  <tr>
    <td>
  
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextPager">
					<td colspan="11">&nbsp;</td>
				</tr>
        <tr class="TextHeader" align="center">
          <td width="8%">Fecha</td>          
          <td width="16%">No. Documento</td>
          <td width="8%">Fecha Documento</td>          
          <td width="15%">No. Cuenta</td>
          <td width="37%">Descripci&oacute;n</td>
          <td width="8%">D&eacute;bito</td>
          <td width="8%">Cr&eacute;dito</td>
        </tr>
<%
double debit = 0.00;
double credit = 0.00;
double tDebit = 0.00;
double tCredit = 0.00;
for (int i=0; i<al.size(); i++)
{
  DocumentTransaction dt = (DocumentTransaction) al.get(i);
  String color = "TextRow02";
  if (i % 2 == 0) color = "TextRow01";

	debit = Double.parseDouble(dt.getDebit());
	credit = Double.parseDouble(dt.getCredit());
%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
          <td><%=dt.getTransDate()%></td>
          <td><%=dt.getDocNo()%></td>
          <td><%=dt.getDocDate()%></td>
          <td><%=dt.getCtaNo()%></td>
          <td align="left"><%=dt.getCtaDesc()%></td>
          <td align="right"><%=(debit == 0)?"":CmnMgr.getFormattedDecimal(debit)%></td>
          <td align="right"><%=(credit == 0)?"":CmnMgr.getFormattedDecimal(credit)%></td>
        </tr>
<%
	tDebit += debit;
	tCredit += credit;
}

if (al.size() > 0)
{
%>              
        <tr class="TextRow06 Text10Bold">
					<td colspan="5" align="right">Total</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tDebit)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tCredit)%></td>
				</tr>
<%
}
%>              
<%fb = new FormBean("form1",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
				<tr class="TextPager">
					<td colspan="11" align="right"><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
				</tr>
<%=fb.formEnd()%>
      </table>
  
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
  
    </td>
  </tr>
</table>        

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
