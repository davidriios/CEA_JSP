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

		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);

		pc.setVAlignment(2);

		pc.addCols(_comp.getNombre(),1,3,15.0f);
		pc.setFont(7, 0);
		pc.addCols("Pg. "+pageNo+" de "+nPages,2,2,15.0f);

		/*pc.addCols(_comp.getNombre(),1,3,15.0f);
		pc.setFont(7, 0);
		pc.addCols("Pg. "+pageNo+" de "+nPages,2,1,15.0f);*/


		pc.setFont(12, 1);
		//pc.addBorderCols("",0,5,1.5f,0.0f,0.0f,0.0f,5.0f);
	   pc.addTable();
	pc.copyTable("headerTop");

	pc.setNoColumnFixWidth(setHeader);
	pc.createTable();
		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols("RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,3);
		pc.setFont(7, 0);
		pc.addCols(""+user,2,1);
	pc.addTable();

	pc.createTable();
		pc.setFont(9, 0);
		pc.addCols("",1,1);

		//pc.addCols("Apdod. "+_comp.getApartadoPostal(),2,1);

		pc.addCols("Apdo. "+_comp.getApartadoPostal(),2,1);

		pc.addCols("",1,1);
		pc.addCols("Tels. "+_comp.getTelefono(),0,1);
		pc.setFont(7, 0);
		pc.addCols(""+currDate,2,1);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			pc.addCols(""+xtraCompanyInfo,1,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols(""+((title != null && !title.trim().equals(""))?title:" "),1,3);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		pc.setFont(9, 0);
		pc.addCols("",0,1);
		pc.addCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,3);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			pc.addCols(""+xtraSubtitle,1,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.addCols(" ",0,5,5.0f);
	pc.addTable();
	pc.copyTable("headerBottom");

	return pc;
}
//hoja de trabajo 
PdfCreator pdfHeader(PdfCreator pc, Compania _comp, String xtraCompanyInfo, String title, String subtitle, String xtraSubtitle, String user, String currDate, int dHeaderSize)
{
	Vector cWidth = new Vector();
		cWidth.addElement(".2");
		cWidth.addElement(".28");
		cWidth.addElement(".04");
		cWidth.addElement(".28");
		cWidth.addElement(".2");

	pc.setNoColumnFixWidth(cWidth);
	pc.createTable("company");
		pc.setFont(12, 1);
        pc.addCols("",0,1);
		//pc.addImageCols(companyImageDir+File.separator+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),60.0f,1);

		pc.setVAlignment(2);

		//pc.addCols(_comp.getNombre(),1,3,15.0f);
		//pc.addCols("",1,1,15.0f);


		//pc.addBorderCols("",0,cWidth.size(),1.5f,0.0f,0.0f,0.0f,5.0f);

		pc.setFont(9, 0);
		pc.addCols("",0,2);
		pc.addCols("",0,2);
		//pc.addCols("",0,1);
		//pc.addCols("RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),2,2);
		pc.setFont(7, 0);
		//pc.addCols(""+user,2,1);

		pc.setFont(9, 0);
		pc.addCols("",1,3);
		pc.addCols("",1,1);
		//pc.addCols("Apdo. "+_comp.getApartadoPostal(),1,1);
		pc.addCols("",1,3);
		pc.addCols("",1,1);
		//pc.addCols("Tels. "+_comp.getTelefono(),1,1);
		pc.setFont(7, 0);
		//pc.addCols(""+currDate,0,1);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addCols("",0,1);
			pc.addCols(""+xtraCompanyInfo,0,3);
			pc.setFont(7, 0);
			pc.addCols("",2,1);
		}

		pc.setFont(9, 0);
		pc.addCols("",0,2);
		pc.addCols(""+((title != null && !title.trim().equals(""))?title:" "),1,2);
		pc.setFont(7, 0);
		pc.addCols("",2,1);

		pc.setFont(9, 0);
		//pc.addCols("",0,1);
		//pc.addCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,3);
		pc.setFont(7, 0);
		//pc.addCols("",2,1);

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals(""))
		{
			pc.setFont(9, 0);
			//pc.addCols("",0,1);
			//pc.addCols(""+xtraSubtitle,1,3);
			pc.setFont(7, 0);
			//pc.addCols("",2,1);
		}

	//	pc.addCols(" ",0,cWidth.size(),5.0f);
	pc.useTable("main");
	pc.addTableToCols("company",1,dHeaderSize);

	return pc;
}

/*Header que trae la informacion del paciente*/
PdfCreator pdfHeader(PdfCreator pc, Compania _comp, CommonDataObject cdoPac, String xtraCompanyInfo, String title, String subtitle, String xtraSubtitle, String user, String currDate, int dHeaderSize)
{
	float cHeight = 12.0f;
	Vector cWidth = new Vector();
		cWidth.addElement(".055");
		cWidth.addElement(".05");
		cWidth.addElement(".079");
		cWidth.addElement(".185");
		cWidth.addElement(".08");
		cWidth.addElement(".15");
		cWidth.addElement(".068");
		cWidth.addElement(".153");
		cWidth.addElement(".054");
		cWidth.addElement(".126");

	Vector vecImage = new Vector();
		vecImage.addElement("0.01");
		vecImage.addElement("0.98");
		vecImage.addElement("0.01");

	pc.setNoColumnFixWidth(vecImage);
		pc.createTable("image", false);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addImageCols(companyImageDir+File.separator+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),60.0f,1);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		//pc.addBorderCols("",0,vecImage.size(),1.5f,0.0f,0.0f,0.0f);

	pc.setNoColumnFixWidth(cWidth);
	pc.createTable("header", false);

		pc.addTableToCols("image",1,cWidth.size());

		pc.setFont(7, 0);
		pc.addBorderCols(user,2,cWidth.size(),0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(currDate,2,cWidth.size(),0.0f,0.0f,0.0f,0.0f);

		pc.setVAlignment(0);

		if (xtraCompanyInfo != null && !xtraCompanyInfo.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addBorderCols(""+xtraCompanyInfo,1,cWidth.size(),0.0f,0.0f,0.0f,0.0f);
		}

		if (title != null && !title.trim().equals(""))
		{
		pc.setFont(9, 0);
		pc.addBorderCols(""+((title != null && !title.trim().equals(""))?title:" "),1,cWidth.size(),0.0f,0.0f,0.0f,0.0f);
		}

		if (subtitle != null && !subtitle.trim().equals(""))
		{
		pc.setFont(9, 0);
		pc.addBorderCols(""+((subtitle != null && !subtitle.trim().equals(""))?subtitle:" "),1,cWidth.size(),0.0f,0.0f,0.0f,0.0f);
		}

		if (xtraSubtitle != null && !xtraSubtitle.trim().equals(""))
		{
			pc.setFont(9, 0);
			pc.addBorderCols(""+xtraSubtitle,1,cWidth.size());
		}

		pc.addBorderCols("",0,cWidth.size(),0.5f,0.0f,0.0f,0.0f, cHeight);

		pc.setFont(6, 0);
		pc.addBorderCols("PID:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("pac_id"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Nombre:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("nombre_paciente"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Ced/Pass:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("identificacion"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Fecha Nac.:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("f_nac"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Edad:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("edad") + "  " + "Sexo: " + cdoPac.getColValue("sexo"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);

		pc.addBorderCols("No. Adm.:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("admision"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Fecha Ingreso:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("fecha_ingreso"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Cama:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("cama"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Area/Centro:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("centro_servicio_desc"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Categoria:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("categoria_desc"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);

		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue(""),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Méd. Tratante:",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("["+cdoPac.getColValue("medico"," ")+"] "+cdoPac.getColValue("nombre_medico"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Méd. Cabecera:",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("["+cdoPac.getColValue("cod_medico_c"," ")+"] "+cdoPac.getColValue("nombre_medico_cabecera"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Religión:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("religion_desc"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols("Tipaje:",0,1,0.0f,0.0f,0.0f,0.0f, cHeight);
		pc.addBorderCols(cdoPac.getColValue("tipo_sangre"),0,1,0.0f,0.0f,0.0f,0.0f, cHeight);

		pc.addBorderCols(" ",0,cWidth.size(),0.0f,0.5f,0.0f,0.0f, cHeight);
	pc.useTable("main");
	pc.addTableToCols("header", 1, dHeaderSize);

	return pc;
}
%>