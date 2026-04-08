import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:provider/provider.dart';
import 'package:turnable_page/turnable_page.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/circular_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/pdf_cache.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';

import '../../../../core/provider/student_provider.dart';

class LibraryScreenView extends StatefulWidget {
  const LibraryScreenView({super.key});

  @override
  State<LibraryScreenView> createState() => _LibraryScreenViewState();
}

class _LibraryScreenViewState extends State<LibraryScreenView> {
  @override
  void didChangeDependencies() {
    Provider.of<CircularProvider>(context, listen: false).getCircularList(
      studCode: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).selectedStudentModel(context).studcode,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        appBar: const CommonAppBar(title: "Library"),
        body: Consumer<CircularProvider>(
          builder: (context, value, child) {
            switch (value.circularListState) {
              case AppStates.Unintialized:
              case AppStates.Initial_Fetching:
                return const Center(child: CircularProgressIndicator());
              case AppStates.Fetched:
                final pdfs = (value.circularListModel ?? [])
                    .where((e) => e.file.toLowerCase().contains('.pdf'))
                    .toList();
                if (pdfs.isEmpty) {
                  return const NoDataWidget(
                    imagePath: "assets/images/no_data.svg",
                    content: "No PDFs found",
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pdfs.length,
                  cacheExtent: 500, // Lazy loading: only cache 500px worth of off-screen items
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = pdfs[index];
                    return _LibraryPdfTile(
                      title: item.circularHead,
                      date: item.circularDate,
                      pdfUrl: item.file,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LibraryPdfViewer(
                              url: item.file,
                              title: item.circularHead,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              case AppStates.NoInterNetConnectionState:
                return NoInternetConnection(
                  ontap: () async {
                    final hasInternet =
                        await InternetConnectivity().hasInternetConnection;
                    if (!hasInternet) {
                      showToast("No internet connection!", context);
                      return;
                    }
                    Provider.of<CircularProvider>(
                      context,
                      listen: false,
                    ).getCircularList(
                      studCode: Provider.of<StudentProvider>(
                        context,
                        listen: false,
                      ).selectedStudentModel(context).studcode,
                    );
                  },
                );
              case AppStates.Error:
                return const Center(child: Text("Error"));
            }
          },
        ),
      ),
    );
  }
}

class _LibraryPdfTile extends StatefulWidget {
  final String title;
  final String date;
  final String pdfUrl;
  final VoidCallback onTap;

  const _LibraryPdfTile({
    required this.title,
    required this.date,
    required this.pdfUrl,
    required this.onTap,
  });

  @override
  State<_LibraryPdfTile> createState() => _LibraryPdfTileState();
}

class _LibraryPdfTileState extends State<_LibraryPdfTile> {
  int? _pageCount;
  bool _isLoadingPages = false;

  @override
  void initState() {
    super.initState();
    // Defer loading until after the widget is built (lazy loading)
    // Only tiles that are actually visible will trigger page count fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPageCount();
      }
    });
  }

  Future<void> _loadPageCount() async {
    if (_isLoadingPages || _pageCount != null) return;
    
    setState(() {
      _isLoadingPages = true;
    });

    try {
      final file = await PdfCache.getFile(widget.pdfUrl);
      final bytes = await file.readAsBytes();
      final doc = await pdfx.PdfDocument.openData(bytes);
      if (mounted) {
        setState(() {
          _pageCount = doc.pagesCount;
          _isLoadingPages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPages = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ConstColors.filledColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ConstColors.borderColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              color: ConstColors.primary,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        widget.date,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      if (_pageCount != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_pageCount ${_pageCount == 1 ? 'page' : 'pages'}',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class LibraryPdfViewer extends StatefulWidget {
  final String url;
  final String title;
  const LibraryPdfViewer({super.key, required this.url, required this.title});

  @override
  State<LibraryPdfViewer> createState() => _LibraryPdfViewerState();
}

class _LibraryPdfViewerState extends State<LibraryPdfViewer> {
  String? _error;
  String? _cachedFilePath;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePdfrxCache();
    _loadCachedFile();
  }

  Future<void> _initializePdfrxCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/pdfrx_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      await TurnablePdf.initPDFLoaders();
    } catch (e) {
      debugPrint('Failed to initialize pdfrx cache: $e');
    }
  }

  Future<void> _loadCachedFile() async {
    try {
      // Load from cache (downloads only if not already cached)
      final file = await PdfCache.getFile(widget.url);
      _cachedFilePath = file.path;
      
      // Load page count from cached file
      final bytes = await file.readAsBytes();
      final doc = await pdfx.PdfDocument.openData(bytes);
      if (!mounted) return;
      setState(() {
        _totalPages = doc.pagesCount;
        _currentPage = _totalPages > 0 ? 1 : 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CommonAppBar(
          title: widget.title,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _buildCurlViewer(),
      ),
    );
  }

  Widget _buildCurlViewer() {
    if (_cachedFilePath == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TurnablePdf.file(
                _cachedFilePath!,
                pageViewMode: PageViewMode.single,
                paperBoundaryDecoration: PaperBoundaryDecoration.modern,
                settings: FlipSettings(
                  flippingTime: 800,
                  swipeDistance: 80.0,
                  cornerTriggerAreaSize: 0.15,
                ),
                onPageChanged: (page, total) {
                  if (mounted) {
                    setState(() {
                      // TurnablePdf provides 0-indexed page numbers (0, 1, 2...)
                      // Convert to 1-indexed for display (1, 2, 3...)
                      final newPage = page + 1;
                      if (newPage < 1) {
                        _currentPage = 1;
                      } else if (_totalPages > 0 && newPage > _totalPages) {
                        _currentPage = _totalPages;
                      } else {
                        _currentPage = newPage;
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Page $_currentPage of $_totalPages',
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

