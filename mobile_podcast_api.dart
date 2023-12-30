
import 'dart:io';

import 'package:anytime/api/podcast/podcast_api.dart';
import 'package:anytime/core/environment.dart';
import 'package:anytime/entities/transcript.dart';
import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart' as podcast_search;


class MobilePodcastApi extends PodcastApi {
  SecurityContext? _defaultSecurityContext;

  List<int> _certificateAuthorityBytes = [];

  @override
  Future<podcast_search.SearchResult> search(
    String term, {
    String? country,
    String? attribute,
    int? limit,
    String? language,
    int version = 0,
    bool explicit = false,
    String? searchProvider,
  }) async {
    var searchParams = {
      'term': term,
      'searchProvider': searchProvider,
    };

    return compute(_search, searchParams);
  }

  @override
  Future<podcast_search.SearchResult> charts({
    int? size = 20,
    String? genre,
    String? searchProvider,
    String? countryCode = '',
  }) async {
    var searchParams = {
      'size': size.toString(),
      'genre': genre,
      'searchProvider': searchProvider,
      'countryCode': countryCode,
    };

    return compute(_charts, searchParams);
  }

  @override
  List<String> genres(String searchProvider) {
    var provider = searchProvider == 'itunes'
        ? const podcast_search.ITunesProvider()
        : podcast_search.PodcastIndexProvider(
            key: podcastIndexKey,
            secret: podcastIndexSecret,
          );

    return podcast_search.Search(
      userAgent: Environment.userAgent(),
      searchProvider: provider,
    ).genres();
  }

  @override
  Future<podcast_search.Podcast> loadFeed(String url) async {
    return _loadFeed(url);
  }

  @override
  Future<podcast_search.Chapters> loadChapters(String url) async {
    return podcast_search.Podcast.loadChaptersByUrl(url: url);
  }

  @override
  Future<podcast_search.Transcript> loadTranscript(TranscriptUrl transcriptUrl) async {
    late podcast_search.TranscriptFormat format;

    switch (transcriptUrl.type) {
      case TranscriptFormat.subrip:
        format = podcast_search.TranscriptFormat.subrip;
        break;
      case TranscriptFormat.json:
        format = podcast_search.TranscriptFormat.json;
        break;
      case TranscriptFormat.unsupported:
        format = podcast_search.TranscriptFormat.unsupported;
        break;
    }

    return podcast_search.Podcast.loadTranscriptByUrl(
        transcriptUrl: podcast_search.TranscriptUrl(url: transcriptUrl.url, type: format));
  }

  static Future<podcast_search.SearchResult> _search(Map<String, String?> searchParams) {
    var term = searchParams['term']!;
    var provider = searchParams['searchProvider'] == 'itunes'
        ? const podcast_search.ITunesProvider()
        : podcast_search.PodcastIndexProvider(
            key: podcastIndexKey,
            secret: podcastIndexSecret,
          );

    return podcast_search.Search(
      userAgent: Environment.userAgent(),
      searchProvider: provider,
    ).search(term).timeout(const Duration(seconds: 30));
  }

  static Future<podcast_search.SearchResult> _charts(Map<String, String?> searchParams) {
    var provider = searchParams['searchProvider'] == 'itunes'
        ? const podcast_search.ITunesProvider()
        : podcast_search.PodcastIndexProvider(
            key: podcastIndexKey,
            secret: podcastIndexSecret,
          );

    var countryCode = searchParams['countryCode'];
    var country = podcast_search.Country.none;

    if (countryCode != null && countryCode.isNotEmpty) {
      country = podcast_search.Country.values.where((element) => element.code == countryCode).first;
    }

    return podcast_search.Search(userAgent: Environment.userAgent(), searchProvider: provider)
        .charts(genre: searchParams['genre']!, country: country, limit: 50)
        .timeout(const Duration(seconds: 30));
  }

  Future<podcast_search.Podcast> _loadFeed(String url) {
    _setupSecurityContext();
    return podcast_search.Podcast.loadFeed(url: url, userAgent: Environment.userAgent());
  }

  void _setupSecurityContext() {
    if (_certificateAuthorityBytes.isNotEmpty && _defaultSecurityContext == null) {
      SecurityContext.defaultContext.setTrustedCertificatesBytes(_certificateAuthorityBytes);
      _defaultSecurityContext = SecurityContext.defaultContext;
    }
  }

  @override
  void addClientAuthorityBytes(List<int> certificateAuthorityBytes) {
    _certificateAuthorityBytes = certificateAuthorityBytes;
  }
}
