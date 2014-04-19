<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="com.apple.InterfaceBuilder3.Cocoa.XIB" version="3.0" toolsVersion="5023" systemVersion="13A603" targetRuntime="MacOSX.Cocoa" propertyAccessControl="none" useAutolayout="YES">
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.CocoaPlugin" version="5023"/>
    </dependencies>
    <objects>
        <customObject id="-2" userLabel="File's Owner" customClass="NSApplication">
            <connections>
                <outlet property="delegate" destination="Voe-Tx-rLC" id="GzC-gU-4Uq"/>
            </connections>
        </customObject>
        <customObject id="-1" userLabel="First Responder" customClass="FirstResponder"/>
        <customObject id="-3" userLabel="Application"/>
        <customObject id="Voe-Tx-rLC" customClass="LSAppDelegate">
            <connections>
                <outlet property="window" destination="QvC-M9-y7g" id="gIp-Ho-8D9"/>
            </connections>
        </customObject>
        <customObject id="YLy-65-1bz" customClass="NSFontManager"/>
        <menu title="Main Menu" systemMenu="main" id="AYu-sK-qS6">
            <items>
                <menuItem title="LevelSearchBenchmarking" id="1Xt-HY-uBw">
                    <modifierMask key="keyEquivalentModifierMask"/>
                    <menu key="submenu" title="LevelSearchBenchmarking" systemMenu="apple" id="uQy-DD-JDr">
                        <items>
                            <menuItem title="About LevelSearchBenchmarking" id="5kV-Vb-QxS">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <connections>
                                    <action selector="orderFrontStandardAboutPanel:" target="-1" id="Exp-CZ-Vem"/>
                                </connections>
                            </menuItem>
                            <menuItem isSeparatorItem="YES" id="VOq-y0-SEH"/>
                            <menuItem title="Preferences…" keyEquivalent="," id="BOF-NM-1cW"/>
                            <menuItem isSeparatorItem="YES" id="wFC-TO-SCJ"/>
                            <menuItem title="Services" id="NMo-om-nkz">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Services" systemMenu="services" id="hz9-B4-Xy5"/>
                            </menuItem>
                            <menuItem isSeparatorItem="YES" id="4je-JR-u6R"/>
                            <menuItem title="Hide LevelSearchBenchmarking" keyEquivalent="h" id="Olw-nP-bQN">
                                <connections>
                                    <action selector="hide:" target="-1" id="PnN-Uc-m68"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Hide Others" keyEquivalent="h" id="Vdr-fp-XzO">
                                <modifierMask key="keyEquivalentModifierMask" option="YES" command="YES"/>
                                <connections>
                                    <action selector="hideOtherApplications:" target="-1" id="VT4-aY-XCT"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Show All" id="Kd2-mp-pUS">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <connections>
                                    <action selector="unhideAllApplications:" target="-1" id="Dhg-Le-xox"/>
                                </connections>
                            </menuItem>
                            <menuItem isSeparatorItem="YES" id="kCx-OE-vgT"/>
                            <menuItem title="Quit LevelSearchBenchmarking" keyEquivalent="q" id="4sb-4s-VLi">
                                <connections>
                                    <action selector="terminate:" target="-1" id="Te7-pn-YzF"/>
                                </connections>
                            </menuItem>
                        </items>
                    </menu>
                </menuItem>
                <menuItem title="File" id="dMs-cI-mzQ">
                    <modifierMask key="keyEquivalentModifierMask"/>
                    <menu key="submenu" title="File" id="bib-Uj-vzu">
                        <items>
                            <menuItem title="New" keyEquivalent="n" id="Was-JA-tGl">
                                <connections>
                                    <action selector="newDocument:" target="-1" id="4Si-XN-c54"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Open…" keyEquivalent="o" id="IAo-SY-fd9">
                                <connections>
                                    <action selector="openDocument:" target="-1" id="bVn-NM-KNZ"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Open Recent" id="tXI-mr-wws">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Open Recent" systemMenu="recentDocuments" id="oas-Oc-fiZ">
                                    <items>
                                        <menuItem title="Clear Menu" id="vNY-rz-j42">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="clearRecentDocuments:" target="-1" id="Daa-9d-B3U"/>
                                            </connections>
                                        </menuItem>
                                    </items>
                                </menu>
                            </menuItem>
                            <menuItem isSeparatorItem="YES" id="m54-Is-iLE"/>
                            <menuItem title="Close" keyEquivalent="w" id="DVo-aG-piG">
                                <connections>
                                    <action selector="performClose:" target="-1" id="HmO-Ls-i7Q"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Save…" keyEquivalent="s" id="pxx-59-PXV">
                                <connections>
                                    <action selector="saveDocument:" target="-1" id="teZ-XB-qJY"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Save As…" keyEquivalent="S" id="Bw7-FT-i3A">
                                <connections>
                                    <action selector="saveDocumentAs:" target="-1" id="mDf-zr-I0C"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Revert to Saved" id="KaW-ft-85H">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <connections>
                                    <action selector="revertDocumentToSaved:" target="-1" id="iJ3-Pv-kwq"/>
                                </connections>
                            </menuItem>
                            <menuItem isSeparatorItem="YES" id="aJh-i4-bef"/>
                            <menuItem title="Page Setup…" keyEquivalent="P" id="qIS-W8-SiK">
                                <modifierMask key="keyEquivalentModifierMask" shift="YES" command="YES"/>
                                <connections>
                                    <action selector="runPageLayout:" target="-1" id="Din-rz-gC5"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Print…" keyEquivalent="p" id="aTl-1u-JFS">
                                <connections>
                                    <action selector="print:" target="-1" id="qaZ-4w-aoO"/>
                                </connections>
                            </menuItem>
                        </items>
                    </menu>
                </menuItem>
                <menuItem title="Edit" id="5QF-Oa-p0T">
                    <modifierMask key="keyEquivalentModifierMask"/>
                    <menu key="submenu" title="Edit" id="W48-6f-4Dl">
                        <items>
                            <menuItem title="Undo" keyEquivalent="z" id="dRJ-4n-Yzg">
                                <connections>
                                    <action selector="undo:" target="-1" id="M6e-cu-g7V"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Redo" keyEquivalent="Z" id="6dh-zS-Vam">
                                <connections>
                                    <action selector="redo:" target="-1" id="oIA-Rs-6OD"/>
                                </connections>
                            </menuItem>
                            <menuItem isSeparatorItem="YES" id="WRV-NI-Exz"/>
                            <menuItem title="Cut" keyEquivalent="x" id="uRl-iY-unG">
                                <connections>
                                    <action selector="cut:" target="-1" id="YJe-68-I9s"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Copy" keyEquivalent="c" id="x3v-GG-iWU">
                                <connections>
                                    <action selector="copy:" target="-1" id="G1f-GL-Joy"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Paste" keyEquivalent="v" id="gVA-U4-sdL">
                                <connections>
                                    <action selector="paste:" target="-1" id="UvS-8e-Qdg"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Paste and Match Style" keyEquivalent="V" id="WeT-3V-zwk">
                                <modifierMask key="keyEquivalentModifierMask" option="YES" command="YES"/>
                                <connections>
                                    <action selector="pasteAsPlainText:" target="-1" id="cEh-KX-wJQ"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Delete" id="pa3-QI-u2k">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <connections>
                                    <action selector="delete:" target="-1" id="0Mk-Ml-PaM"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Select All" keyEquivalent="a" id="Ruw-6m-B2m">
                                <connections>
                                    <action selector="selectAll:" target="-1" id="VNm-Mi-diN"/>
                                </connections>
                            </menuItem>
                            <menuItem isSeparatorItem="YES" id="uyl-h8-XO2"/>
                            <menuItem title="Find" id="4EN-yA-p0u">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Find" id="1b7-l0-nxx">
                                    <items>
                                        <menuItem title="Find…" tag="1" keyEquivalent="f" id="Xz5-n4-O0W">
                                            <connections>
                                                <action selector="performFindPanelAction:" target="-1" id="cD7-Qs-BN4"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Find and Replace…" tag="12" keyEquivalent="f" id="YEy-JH-Tfz">
                                            <modifierMask key="keyEquivalentModifierMask" option="YES" command="YES"/>
                                            <connections>
                                                <action selector="performFindPanelAction:" target="-1" id="WD3-Gg-5AJ"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Find Next" tag="2" keyEquivalent="g" id="q09-fT-Sye">
                                            <connections>
                                                <action selector="performFindPanelAction:" target="-1" id="NDo-RZ-v9R"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Find Previous" tag="3" keyEquivalent="G" id="OwM-mh-QMV">
                                            <connections>
                                                <action selector="performFindPanelAction:" target="-1" id="HOh-sY-3ay"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Use Selection for Find" tag="7" keyEquivalent="e" id="buJ-ug-pKt">
                                            <connections>
                                                <action selector="performFindPanelAction:" target="-1" id="U76-nv-p5D"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Jump to Selection" keyEquivalent="j" id="S0p-oC-mLd">
                                            <connections>
                                                <action selector="centerSelectionInVisibleArea:" target="-1" id="IOG-6D-g5B"/>
                                            </connections>
                                        </menuItem>
                                    </items>
                                </menu>
                            </menuItem>
                            <menuItem title="Spelling and Grammar" id="Dv1-io-Yv7">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Spelling" id="3IN-sU-3Bg">
                                    <items>
                                        <menuItem title="Show Spelling and Grammar" keyEquivalent=":" id="HFo-cy-zxI">
                                            <connections>
                                                <action selector="showGuessPanel:" target="-1" id="vFj-Ks-hy3"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Check Document Now" keyEquivalent=";" id="hz2-CU-CR7">
                                            <connections>
                                                <action selector="checkSpelling:" target="-1" id="fz7-VC-reM"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem isSeparatorItem="YES" id="bNw-od-mp5"/>
                                        <menuItem title="Check Spelling While Typing" id="rbD-Rh-wIN">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleContinuousSpellChecking:" target="-1" id="7w6-Qz-0kB"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Check Grammar With Spelling" id="mK6-2p-4JG">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleGrammarChecking:" target="-1" id="muD-Qn-j4w"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Correct Spelling Automatically" id="78Y-hA-62v">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleAutomaticSpellingCorrection:" target="-1" id="2lM-Qi-WAP"/>
                                            </connections>
                                        </menuItem>
                                    </items>
                                </menu>
                            </menuItem>
                            <menuItem title="Substitutions" id="9ic-FL-obx">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Substitutions" id="FeM-D8-WVr">
                                    <items>
                                        <menuItem title="Show Substitutions" id="z6F-FW-3nz">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="orderFrontSubstitutionsPanel:" target="-1" id="oku-mr-iSq"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem isSeparatorItem="YES" id="gPx-C9-uUO"/>
                                        <menuItem title="Smart Copy/Paste" id="9yt-4B-nSM">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleSmartInsertDelete:" target="-1" id="3IJ-Se-DZD"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Smart Quotes" id="hQb-2v-fYv">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleAutomaticQuoteSubstitution:" target="-1" id="ptq-xd-QOA"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Smart Dashes" id="rgM-f4-ycn">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleAutomaticDashSubstitution:" target="-1" id="oCt-pO-9gS"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Smart Links" id="cwL-P1-jid">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleAutomaticLinkDetection:" target="-1" id="Gip-E3-Fov"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Data Detectors" id="tRr-pd-1PS">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleAutomaticDataDetection:" target="-1" id="R1I-Nq-Kbl"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Text Replacement" id="HFQ-gK-NFA">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleAutomaticTextReplacement:" target="-1" id="DvP-Fe-Py6"/>
                                            </connections>
                                        </menuItem>
                                    </items>
                                </menu>
                            </menuItem>
                            <menuItem title="Transformations" id="2oI-Rn-ZJC">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Transformations" id="c8a-y6-VQd">
                                    <items>
                                        <menuItem title="Make Upper Case" id="vmV-6d-7jI">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="uppercaseWord:" target="-1" id="sPh-Tk-edu"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Make Lower Case" id="d9M-CD-aMd">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="lowercaseWord:" target="-1" id="iUZ-b5-hil"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Capitalize" id="UEZ-Bs-lqG">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="capitalizeWord:" target="-1" id="26H-TL-nsh"/>
                                            </connections>
                                        </menuItem>
                                    </items>
                                </menu>
                            </menuItem>
                            <menuItem title="Speech" id="xrE-MZ-jX0">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Speech" id="3rS-ZA-NoH">
                                    <items>
                                        <menuItem title="Start Speaking" id="Ynk-f8-cLZ">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="startSpeaking:" target="-1" id="654-Ng-kyl"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Stop Speaking" id="Oyz-dy-DGm">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="stopSpeaking:" target="-1" id="dX8-6p-jy9"/>
                                            </connections>
                                        </menuItem>
                                    </items>
                                </menu>
                            </menuItem>
                        </items>
                    </menu>
                </menuItem>
                <menuItem title="Format" id="jxT-CU-nIS">
                    <modifierMask key="keyEquivalentModifierMask"/>
                    <menu key="submenu" title="Format" id="GEO-Iw-cKr">
                        <items>
                            <menuItem title="Font" id="Gi5-1S-RQB">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Font" systemMenu="font" id="aXa-aM-Jaq">
                                    <items>
                                        <menuItem title="Show Fonts" keyEquivalent="t" id="Q5e-8K-NDq">
                                            <connections>
                                                <action selector="orderFrontFontPanel:" target="YLy-65-1bz" id="WHr-nq-2xA"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Bold" tag="2" keyEquivalent="b" id="GB9-OM-e27">
                                            <connections>
                                                <action selector="addFontTrait:" target="YLy-65-1bz" id="hqk-hr-sYV"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Italic" tag="1" keyEquivalent="i" id="Vjx-xi-njq">
                                            <connections>
                                                <action selector="addFontTrait:" target="YLy-65-1bz" id="IHV-OB-c03"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Underline" keyEquivalent="u" id="WRG-CD-K1S">
                                            <connections>
                                                <action selector="underline:" target="-1" id="FYS-2b-JAY"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem isSeparatorItem="YES" id="5gT-KC-WSO"/>
                                        <menuItem title="Bigger" tag="3" keyEquivalent="+" id="Ptp-SP-VEL">
                                            <connections>
                                                <action selector="modifyFont:" target="YLy-65-1bz" id="Uc7-di-UnL"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Smaller" tag="4" keyEquivalent="-" id="i1d-Er-qST">
                                            <connections>
                                                <action selector="modifyFont:" target="YLy-65-1bz" id="HcX-Lf-eNd"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem isSeparatorItem="YES" id="kx3-Dk-x3B"/>
                                        <menuItem title="Kern" id="jBQ-r6-VK2">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <menu key="submenu" title="Kern" id="tlD-Oa-oAM">
                                                <items>
                                                    <menuItem title="Use Default" id="GUa-eO-cwY">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="useStandardKerning:" target="-1" id="6dk-9l-Ckg"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Use None" id="cDB-IK-hbR">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="turnOffKerning:" target="-1" id="U8a-gz-Maa"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Tighten" id="46P-cB-AYj">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="tightenKerning:" target="-1" id="hr7-Nz-8ro"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Loosen" id="ogc-rX-tC1">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="loosenKerning:" target="-1" id="8i4-f9-FKE"/>
                                                        </connections>
                                                    </menuItem>
                                                </items>
                                            </menu>
                                        </menuItem>
                                        <menuItem title="Ligatures" id="o6e-r0-MWq">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <menu key="submenu" title="Ligatures" id="w0m-vy-SC9">
                                                <items>
                                                    <menuItem title="Use Default" id="agt-UL-0e3">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="useStandardLigatures:" target="-1" id="7uR-wd-Dx6"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Use None" id="J7y-lM-qPV">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="turnOffLigatures:" target="-1" id="iX2-gA-Ilz"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Use All" id="xQD-1f-W4t">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="useAllLigatures:" target="-1" id="KcB-kA-TuK"/>
                                                        </connections>
                                                    </menuItem>
                                                </items>
                                            </menu>
                                        </menuItem>
                                        <menuItem title="Baseline" id="OaQ-X3-Vso">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <menu key="submenu" title="Baseline" id="ijk-EB-dga">
                                                <items>
                                                    <menuItem title="Use Default" id="3Om-Ey-2VK">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="unscript:" target="-1" id="0vZ-95-Ywn"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Superscript" id="Rqc-34-cIF">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="superscript:" target="-1" id="3qV-fo-wpU"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Subscript" id="I0S-gh-46l">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="subscript:" target="-1" id="Q6W-4W-IGz"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Raise" id="2h7-ER-AoG">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="raiseBaseline:" target="-1" id="4sk-31-7Q9"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem title="Lower" id="1tx-W0-xDw">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="lowerBaseline:" target="-1" id="OF1-bc-KW4"/>
                                                        </connections>
                                                    </menuItem>
                                                </items>
                                            </menu>
                                        </menuItem>
                                        <menuItem isSeparatorItem="YES" id="Ndw-q3-faq"/>
                                        <menuItem title="Show Colors" keyEquivalent="C" id="bgn-CT-cEk">
                                            <connections>
                                                <action selector="orderFrontColorPanel:" target="-1" id="mSX-Xz-DV3"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem isSeparatorItem="YES" id="iMs-zA-UFJ"/>
                                        <menuItem title="Copy Style" keyEquivalent="c" id="5Vv-lz-BsD">
                                            <modifierMask key="keyEquivalentModifierMask" option="YES" command="YES"/>
                                            <connections>
                                                <action selector="copyFont:" target="-1" id="GJO-xA-L4q"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Paste Style" keyEquivalent="v" id="vKC-jM-MkH">
                                            <modifierMask key="keyEquivalentModifierMask" option="YES" command="YES"/>
                                            <connections>
                                                <action selector="pasteFont:" target="-1" id="JfD-CL-leO"/>
                                            </connections>
                                        </menuItem>
                                    </items>
                                </menu>
                            </menuItem>
                            <menuItem title="Text" id="Fal-I4-PZk">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <menu key="submenu" title="Text" id="d9c-me-L2H">
                                    <items>
                                        <menuItem title="Align Left" keyEquivalent="{" id="ZM1-6Q-yy1">
                                            <connections>
                                                <action selector="alignLeft:" target="-1" id="zUv-R1-uAa"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Center" keyEquivalent="|" id="VIY-Ag-zcb">
                                            <connections>
                                                <action selector="alignCenter:" target="-1" id="spX-mk-kcS"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Justify" id="J5U-5w-g23">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="alignJustified:" target="-1" id="ljL-7U-jND"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Align Right" keyEquivalent="}" id="wb2-vD-lq4">
                                            <connections>
                                                <action selector="alignRight:" target="-1" id="r48-bG-YeY"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem isSeparatorItem="YES" id="4s2-GY-VfK"/>
                                        <menuItem title="Writing Direction" id="H1b-Si-o9J">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <menu key="submenu" title="Writing Direction" id="8mr-sm-Yjd">
                                                <items>
                                                    <menuItem title="Paragraph" enabled="NO" id="ZvO-Gk-QUH">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                    </menuItem>
                                                    <menuItem id="YGs-j5-SAR">
                                                        <string key="title">	Default</string>
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="makeBaseWritingDirectionNatural:" target="-1" id="qtV-5e-UBP"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem id="Lbh-J2-qVU">
                                                        <string key="title">	Left to Right</string>
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="makeBaseWritingDirectionLeftToRight:" target="-1" id="S0X-9S-QSf"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem id="jFq-tB-4Kx">
                                                        <string key="title">	Right to Left</string>
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="makeBaseWritingDirectionRightToLeft:" target="-1" id="5fk-qB-AqJ"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem isSeparatorItem="YES" id="swp-gr-a21"/>
                                                    <menuItem title="Selection" enabled="NO" id="cqv-fj-IhA">
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                    </menuItem>
                                                    <menuItem id="Nop-cj-93Q">
                                                        <string key="title">	Default</string>
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="makeTextWritingDirectionNatural:" target="-1" id="lPI-Se-ZHp"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem id="BgM-ve-c93">
                                                        <string key="title">	Left to Right</string>
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="makeTextWritingDirectionLeftToRight:" target="-1" id="caW-Bv-w94"/>
                                                        </connections>
                                                    </menuItem>
                                                    <menuItem id="RB4-Sm-HuC">
                                                        <string key="title">	Right to Left</string>
                                                        <modifierMask key="keyEquivalentModifierMask"/>
                                                        <connections>
                                                            <action selector="makeTextWritingDirectionRightToLeft:" target="-1" id="EXD-6r-ZUu"/>
                                                        </connections>
                                                    </menuItem>
                                                </items>
                                            </menu>
                                        </menuItem>
                                        <menuItem isSeparatorItem="YES" id="fKy-g9-1gm"/>
                                        <menuItem title="Show Ruler" id="vLm-3I-IUL">
                                            <modifierMask key="keyEquivalentModifierMask"/>
                                            <connections>
                                                <action selector="toggleRuler:" target="-1" id="FOx-HJ-KwY"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Copy Ruler" keyEquivalent="c" id="MkV-Pr-PK5">
                                            <modifierMask key="keyEquivalentModifierMask" control="YES" command="YES"/>
                                            <connections>
                                                <action selector="copyRuler:" target="-1" id="71i-fW-3W2"/>
                                            </connections>
                                        </menuItem>
                                        <menuItem title="Paste Ruler" keyEquivalent="v" id="LVM-kO-fVI">
                                            <modifierMask key="keyEquivalentModifierMask" control="YES" command="YES"/>
                                            <connections>
                                                <action selector="pasteRuler:" target="-1" id="cSh-wd-qM2"/>
                                            </connections>
                                        </menuItem>
                                    </items>
                                </menu>
                            </menuItem>
                        </items>
                    </menu>
                </menuItem>
                <menuItem title="View" id="H8h-7b-M4v">
                    <modifierMask key="keyEquivalentModifierMask"/>
                    <menu key="submenu" title="View" id="HyV-fh-RgO">
                        <items>
                            <menuItem title="Show Toolbar" keyEquivalent="t" id="snW-S8-Cw5">
                                <modifierMask key="keyEquivalentModifierMask" option="YES" command="YES"/>
                                <connections>
                                    <action selector="toggleToolbarShown:" target="-1" id="BXY-wc-z0C"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Customize Toolbar…" id="1UK-8n-QPP">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <connections>
                                    <action selector="runToolbarCustomizationPalette:" target="-1" id="pQI-g3-MTW"/>
                                </connections>
                            </menuItem>
                        </items>
                    </menu>
                </menuItem>
                <menuItem title="Window" id="aUF-d1-5bR">
                    <modifierMask key="keyEquivalentModifierMask"/>
                    <menu key="submenu" title="Window" systemMenu="window" id="Td7-aD-5lo">
                        <items>
                            <menuItem title="Minimize" keyEquivalent="m" id="OY7-WF-poV">
                                <connections>
                                    <action selector="performMiniaturize:" target="-1" id="VwT-WD-YPe"/>
                                </connections>
                            </menuItem>
                            <menuItem title="Zoom" id="R4o-n2-Eq4">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <connections>
                                    <action selector="performZoom:" target="-1" id="DIl-cC-cCs"/>
                                </connections>
                            </menuItem>
                            <menuItem isSeparatorItem="YES" id="eu3-7i-yIM"/>
                            <menuItem title="Bring All to Front" id="LE2-aR-0XJ">
                                <modifierMask key="keyEquivalentModifierMask"/>
                                <connections>
                                    <action selector="arrangeInFront:" target="-1" id="DRN-fu-gQh"/>
                                </connections>
                            </menuItem>
                        </items>
                    </menu>
                </menuItem>
                <menuItem title="Help" id="wpr-3q-Mcd">
                    <modifierMask key="keyEquivalentModifierMask"/>
                    <menu key="submenu" title="Help" systemMenu="help" id="F2S-fz-NVQ">
                        <items>
                            <menuItem title="LevelSearchBenchmarking Help" keyEquivalent="?" id="FKE-Sm-Kum">
                                <connections>
                                    <action selector="showHelp:" target="-1" id="y7X-2Q-9no"/>
                                </connections>
                            </menuItem>
                        </items>
                    </menu>
                </menuItem>
            </items>
        </menu>
        <window title="LevelSearchBenchmarking" allowsToolTipsWhenApplicationIsInactive="NO" autorecalculatesKeyViewLoop="NO" releasedWhenClosed="NO" animationBehavior="default" id="QvC-M9-y7g">
            <windowStyleMask key="styleMask" titled="YES" closable="YES" miniaturizable="YES" resizable="YES"/>
            <windowPositionMask key="initialPositionMask" leftStrut="YES" rightStrut="YES" topStrut="YES" bottomStrut="YES"/>
            <rect key="contentRect" x="335" y="390" width="480" height="360"/>
            <rect key="screenRect" x="0.0" y="0.0" width="1680" height="1028"/>
            <view key="contentView" id="EiT-Mj-1SZ">
                <rect key="frame" x="0.0" y="0.0" width="480" height="360"/>
                <autoresizingMask key="autoresizingMask"/>
            </view>
        </window>
    </objects>
</document>
