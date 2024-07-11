<%@ page import="issi.admin.UserDetail" %>
<%@ page import="issi.admin.Compania" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%!

String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
PdfCreator pdfHeader(PdfCreator pc, Compania _comp, int pageNo, int nPages, String title, String subtitle, String user, String currDate)
{
	return pdfHeader(pc, _comp, pageNo, nPages, title, subtitle, user, currDate, null, null);
}

PdfCreator pdfHeader(PdfCreator pc, Compania _comp, int pageNo, int nPages, String title, String subtitle, String user, String currDate, String xtraCompanyInfo, String xtraSubtitle)
{
	Vector setHeader = new Vector();
		setHeader.addElement(".2");
		setHeader.addElement(".28");
		setHeader.addElement(".04");
		setHeader.addElement(".28");
		setHeader.addElement(".2");

	pc.setNoColumnFixWidth(setHeader);
	pc.createTable();
		pc.setFont(12, 1);

		//pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);

		pc.setVAlignment(2);

		//pc.addCols(_comp.getNombre(),1,3,15.0f);
		pc.setFont(7, 0);
		//pc.addCols("Pg. "+pageNo+" de "+nPages,2,1,15.0f);

		//pc.addCols(_comp.getNombre(),1,3,15.0f);
		pc.setFont(7, 0);
		//pc.addCols("Pg. "+pageNo+" de "+nPages,2,1,15.0f);


		pc.setFont(12, 1);
		//pc.addBorderCols("",0,5,1.5f,0.0f,0.0f,0.0f,5.0f);
	pc.addTable();
	pc.copyTable("headerTop");

	pc.setNoColumnFixWidth(setHeader);
	pc.createTable();
		pc.setFont(9, 0);
		pc.addCols("",0,1);
		//pc.addCols("RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,3);
		pc.setFont(7, 0);
		//pc.addCols(""+user,2,1);
	pc.addTable();

	pc.createTable();
		pc.setFont(9, 0);
		pc.addCols("",1,1);

		//pc.addCols("Apdod. "+_comp.getApartadoPostal(),2,1);

		//pc.addCols("Apdo. "+_comp.getApartadoPostal(),2,1);

		pc.addCols("",1,1);
		//pc.addCols("Tels. "+_comp.getTelefono(),0,1);
		pc.setFont(7, 0);
		//pc.addCols(""+currDate,2,1);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			//pc.addCols(""+xtraCompanyInfo,1,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		//pc.addCols(""+((title != null && !title.trim().equals(""))?title:" "),1,3);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		//pc.addCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,3);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			//pc.addCols(""+xtraSubtitle,1,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.addCols(" ",0,5,5.0f);
	pc.addTable();
	//pc.copyTable("headerBottom");

	return pc;
}

PdfCreator pdfHeader(PdfCreator pc, Compania _comp, String xtraCompanyInfo, String title, String subtitle, String xtraSubtitle, String user, String currDate, int dHeaderSize)
{
	Vector cWidth = new Vector();
		cWidth.addElement(".2");
		cWidth.addElement(".28");
		cWidth.addElement(".04");
		cWidth.addElement(".28");
		cWidth.addElement(".2");

	pc.setNoInnerColumnFixWidth(cWidth);
	pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 1));
	pc.createInnerTable();
		pc.setFont(12, 1);

		//pc.addInnerTableImageCols(companyImageDir+File.separator+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);

		pc.setVAlignment(2);

		//pc.addInnerTableCols(_comp.getNombre(),1,3,15.0f);
		pc.addInnerTableCols("",1,1,15.0f);


		//pc.addInnerTableBorderCols("",0,cWidth.size(),1.5f,0.0f,0.0f,0.0f,5.0f);

		pc.setFont(9, 0);
//		pc.addInnerTableCols("",0,1);
		//pc.addInnerTableCols("RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,3);
		pc.setFont(7, 0);
		//pc.addInnerTableCols(""+user,2,1);

		pc.setFont(9, 0);
		//pc.addInnerTableCols("",1,1);
		//pc.addInnerTableCols("Apdo. "+_comp.getApartadoPostal(),2,1);
		pc.addInnerTableCols("",1,1);
		//pc.addInnerTableCols("Tels. "+_comp.getTelefono(),0,1);
		pc.setFont(7, 0);
		pc.addInnerTableCols(""+currDate,2,5);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addInnerTableCols("",0,1);
			//pc.addInnerTableCols(""+xtraCompanyInfo,1,3);
			pc.setFont(7, 0);
			pc.addInnerTableCols("",2,1);
		}

		pc.setFont(9, 0);
		pc.addInnerTableCols("",0,1);
		//pc.addInnerTableCols(""+((title != null && !title.trim().equals(""))?title:" "),1,3);
		pc.setFont(7, 0);
		pc.addInnerTableCols("",2,1);

		pc.setFont(9, 0);
//		pc.addInnerTableCols("",0,1);
		//pc.addInnerTableCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,3);
		pc.setFont(7, 0);
		pc.addInnerTableCols("",2,1);

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addInnerTableCols("",0,1);
			//pc.addInnerTableCols(""+xtraSubtitle,1,3);
			pc.setFont(7, 0);
			pc.addInnerTableCols("",2,1);
		}

		pc.addInnerTableCols(" ",0,cWidth.size(),5.0f);
	pc.addInnerTableToCols(dHeaderSize);

	return pc;
}
%>